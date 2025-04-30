import unittest
from unittest.mock import patch, MagicMock, mock_open
import logging
import serial
import sys
import io
import argparse
from src.Bootloader import HexParser, SerialHandler, Bootloader, RECORDS, RESPONSE

class TestHexParser(unittest.TestCase):
    def setUp(self):
        self.hex_data = ":020000040800F2\n:100000000102030405060708090A0B0C0D0E0F10\n:00000001FF\n"
        self.invalid_hex_data = "invalid_record\n"
        self.logger = MagicMock()

    def test_parse_file_valid(self):
        # Test parsing a valid Intel HEX file
        with patch("builtins.open", mock_open(read_data=self.hex_data)):
            parser = HexParser("dummy.hex", self.logger)
            records = parser.get_records()
            self.assertEqual(len(records), 3)
            self.assertEqual(records[0], ":020000040800F2\n")
            self.assertEqual(records[1], ":100000000102030405060708090A0B0C0D0E0F10\n")
            self.assertEqual(records[2], ":00000001FF\n")
            self.assertEqual(parser.get_byteCount(), 18)  # 2 + 16 + 0 bytes
            self.assertEqual(parser.get_recordCount(), 3)

    def test_parse_file_empty(self):
        # Test parsing an empty file
        with patch("builtins.open", mock_open(read_data="")):
            parser = HexParser("empty.hex", self.logger)
            self.assertEqual(parser.get_records(), [])
            self.assertEqual(parser.get_byteCount(), 0)
            self.assertEqual(parser.get_recordCount(), 0)

    def test_parse_file_invalid(self):
        # Test parsing a file with invalid records (should raise ValueError)
        with patch("builtins.open", mock_open(read_data=self.invalid_hex_data)):
            with self.assertRaises(ValueError):
                parser = HexParser("invalid.hex", self.logger)

class TestSerialHandler(unittest.TestCase):
    def setUp(self):
        self.logger = MagicMock()
        self.serial_handler = SerialHandler("COM3", self.logger)

    @patch("serial.Serial")
    def test_open_port_success(self, mock_serial):
        # Test opening the serial port successfully
        mock_serial_instance = MagicMock()
        mock_serial.return_value = mock_serial_instance
        self.serial_handler.open_port()
        self.assertEqual(self.serial_handler.serial, mock_serial_instance)
        mock_serial.assert_called_with("COM3", 115200, timeout=1)

    @patch("serial.Serial")
    def test_open_port_failure(self, mock_serial):
        # Test failure to open the serial port
        mock_serial.side_effect = serial.SerialException("Port not found")
        with self.assertRaises(serial.SerialException):
            self.serial_handler.open_port()

    @patch("serial.Serial")
    def test_close_port(self, mock_serial):
        # Test closing the serial port
        mock_serial_instance = MagicMock()
        mock_serial.return_value = mock_serial_instance
        self.serial_handler.open_port()
        self.serial_handler.close_port()
        mock_serial_instance.close.assert_called_once()

    @patch("serial.Serial")
    def test_send_data(self, mock_serial):
        # Test sending data over the serial port
        mock_serial_instance = MagicMock()
        mock_serial_instance.is_open = True
        mock_serial.return_value = mock_serial_instance
        self.serial_handler.open_port()
        self.serial_handler.send_data(":00000002FE\n")
        mock_serial_instance.write.assert_called_once_with(b":00000002FE\n")

    @patch("serial.Serial")
    def test_send_data_port_not_open(self, mock_serial):
        # Test sending data when the port is not open
        self.serial_handler.serial = None
        with self.assertRaises(serial.SerialException):
            self.serial_handler.send_data(":00000002FE\n")

    @patch("serial.Serial")
    def test_read_byte(self, mock_serial):
        # Test reading a byte from the serial port
        mock_serial_instance = MagicMock()
        mock_serial_instance.is_open = True
        mock_serial_instance.read.return_value = b"\x10"
        mock_serial.return_value = mock_serial_instance
        self.serial_handler.open_port()
        byte = self.serial_handler.read_byte()
        self.assertEqual(byte, b"\x10")
        mock_serial_instance.read.assert_called_once_with(1)

class TestBootloader(unittest.TestCase):
    def setUp(self):
        # Create an argparse.Namespace object with default configuration
        self.args = argparse.Namespace(
            port="COM3",
            file="firmware.hex",
            verbose=False,
            log_file=None
        )

        # Pass the Namespace object to Bootloader
        self.bootloader = Bootloader(args=self.args)

        # Suppress logging output during tests
        logging.getLogger().setLevel(logging.CRITICAL)

    def test_parse_arguments_minimal(self):
        # Test parsing minimal arguments
        with patch("sys.argv", ["Bootloader.py", "-p", "COM3", "firmware.hex"]):
            bootloader = Bootloader()  # args=None, will parse sys.argv
            self.assertEqual(bootloader.args.port, "COM3")
            self.assertEqual(bootloader.args.file, "firmware.hex")
            self.assertFalse(bootloader.args.verbose)
            self.assertIsNone(bootloader.args.log_file)

    def test_parse_arguments_verbose(self):
        # Test parsing with verbose flag
        with patch("sys.argv", ["Bootloader.py", "-p", "COM3", "-v", "firmware.hex"]):
            bootloader = Bootloader()  # args=None, will parse sys.argv
            self.assertTrue(bootloader.args.verbose)

    def test_parse_arguments_log_file(self):
        # Test parsing with log file
        with patch("sys.argv", ["Bootloader.py", "-p", "COM3", "-l", "test.log", "firmware.hex"]):
            bootloader = Bootloader()  # args=None, will parse sys.argv
            self.assertEqual(bootloader.args.log_file, "test.log")

    def test_generate_record_nop(self):
        # Test generating a NOP record
        record = self.bootloader.generateRecord(RECORDS.NOP)
        self.assertEqual(record, ":00000002FE\n")

    def test_generate_record_bsl_start(self):
        # Test generating a BSL_START record
        record = self.bootloader.generateRecord(RECORDS.BSL_START)
        self.assertEqual(record, ":00000003FD\n")

    def test_generate_record_eof(self):
        # Test generating an EOF record
        record = self.bootloader.generateRecord(RECORDS.EOF)
        self.assertEqual(record, ":00000001FF\n")

    def test_generate_record_invalid(self):
        # Test generating an invalid record type
        with self.assertRaises(ValueError):
            self.bootloader.generateRecord(RECORDS.DATA)

    @patch.object(SerialHandler, "send_data")
    @patch.object(SerialHandler, "read_byte")
    def test_transaction_ack(self, mock_read_byte, mock_send_data):
        # Test transaction with an ACK response
        mock_read_byte.return_value = b"\x10"
        self.bootloader.serial_handler = SerialHandler("COM3", self.bootloader.logger)
        response = self.bootloader.transaction(":00000002FE\n")
        self.assertEqual(response, RESPONSE.ACK)
        mock_send_data.assert_called_once()
        mock_read_byte.assert_called_once()

    @patch.object(SerialHandler, "send_data")
    @patch.object(SerialHandler, "read_byte")
    def test_transaction_triple_nack(self, mock_read_byte, mock_send_data):
        # Test transaction with no valid response (triple NACK)
        mock_read_byte.return_value = b"\xFF"  # Invalid response
        self.bootloader.serial_handler = SerialHandler("COM3", self.bootloader.logger)
        response = self.bootloader.transaction(":00000002FE\n")
        self.assertEqual(response, RESPONSE.TRIPLE_NACK)
        self.assertEqual(mock_send_data.call_count, 3)  # Should retry 3 times
        self.assertEqual(mock_read_byte.call_count, 3)

    def test_handle_response_ack(self):
        # Test handling an ACK response
        self.bootloader.handleResponse(RESPONSE.ACK)
        # Should not raise an exception

    def test_handle_response_no_target(self):
        # Test handling a NO_TARGET response
        with self.assertRaises(serial.SerialException) as cm:
            self.bootloader.handleResponse(RESPONSE.NO_TARGET)
        self.assertEqual(str(cm.exception), "No Target Detected by Interface")

    def test_handle_response_triple_nack(self):
        # Test handling a TRIPLE_NACK response
        with self.assertRaises(serial.SerialException) as cm:
            self.bootloader.handleResponse(RESPONSE.TRIPLE_NACK)
        self.assertEqual(str(cm.exception), "Triple NACK from Interface/Target")

    def test_handle_response_none(self):
        # Test handling a NONE response
        with self.assertRaises(serial.SerialException) as cm:
            self.bootloader.handleResponse(RESPONSE.NONE)
        self.assertEqual(str(cm.exception), "No Response from Target")

if __name__ == "__main__":
    unittest.main()
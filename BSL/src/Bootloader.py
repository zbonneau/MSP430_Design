import argparse
import serial
import logging
from enum import Enum
import sys
import time

class RECORDS(Enum):   
    DATA = 0
    EOF  = 1
    NOP  = 2
    BSL_START = 3

class RESPONSE(Enum):
    NONE = 0
    ACK  = 0x10
    NACK = 0x11
    NO_TARGET = 0x20
    TRIPLE_NACK = 0x21

class CustomStreamHandler(logging.StreamHandler):
    """Custom handler to allow logging with carriage returns instead of newlines"""
    def emit(self, record):
        try:
            msg = self.format(record)
            stream = self.stream
            # Check if the message is marked for carriage return (using a custom attribute)
            if getattr(record, "use_cr", False):
                stream.write(msg + "\r")
            else:
                stream.write(msg + "\n")
            self.flush()
        except Exception:
            self.handleError(record)

class HexParser:
    def __init__(self, file_path:str, logger:logging.Logger)->None:
        self.file_path:str = file_path
        self.records:list[str] = []
        self.byteCount:int = 0
        self.logger = logger
        self.parse_file()
        
    def parse_file(self)->None:
        """Parse Intel HEX file and extract records"""
        try:
            with open(self.file_path, "r", encoding="ascii") as file:
                for record in file:
                    self.records.append(record)
                    byteCount = record[1:3]
                    self.byteCount += int(byteCount, base=16)
        except ValueError as e:
            self.logger.error(f"Value Error Encountered during hex parse: {e}")
            raise
        except FileNotFoundError as e:
            self.logger.error(f"File Error Encountered during hex parse: {e}")
            raise
    
    def get_records(self)->list[str]:
        """Get Records from HexParser and return as list of strings"""
        return self.records

    def get_byteCount(self)->int:
        return self.byteCount
    
    def get_recordCount(self)->int:
        return len(self.records)

class SerialHandler:
    def __init__(self, port:str, logger:logging.Logger, baud_rate:int = 115200, timeout:float = 1):
        self.port:str = port
        self.baud_rate:int = baud_rate
        self.timeout = timeout
        self.logger = logger
        self.serial:serial.Serial = None

    def open_port(self)->None:
        """Open the Serial Port"""
        try:
            self.serial = serial.Serial(self.port, self.baud_rate, timeout=self.timeout)
            self.logger.info(f"Opened serial port {self.port} at {self.baud_rate} baud.")
        except serial.SerialException as e:
            self.logger.error(f"Error opening serial port {self.port}: {e}")
            raise

    def close_port(self):
        """Close the serial port"""
        if self.serial and self.serial.is_open:
            self.serial.close()
            self.logger.debug(f"Closed serial port {self.port}.")
    
    def send_data(self, data:str):
        """ Send data over serial port"""
        if self.serial and self.serial.is_open:
            self.serial.write(data.encode())
            # self.logger.debug(f"Serial data: {data}")
        else:
            self.logger.error("Serial Port is not open.")
            raise serial.SerialException("Serial Port is not open.")
        
    def read_byte(self)->bytes:
        """Read a single byte from the serial port"""
        if self.serial and self.serial.is_open:
            byte = self.serial.read(1)
            # self.logger.debug(f"Received Byte: {byte}")
            return byte
        else:
            self.logger.error("Serial Port is not open.")
            raise serial.SerialException("Serial Port is not open.")

class Bootloader:
    def __init__(self, args:argparse.Namespace|None = None):
        self.args = args
        self.hex_parser:HexParser = None
        self.serial_handler:SerialHandler = None
        self.logger = logging.getLogger(__name__)
        self.setup_logging()
    
    def setup_logging(self)->None:
        """Set up logging to console and to optionally add a file"""
        self.logger.setLevel(logging.DEBUG)

        # Console logger (errors only by default)
        console_handler = CustomStreamHandler(sys.stdout)
        console_handler.setLevel(logging.INFO)
        # console_handler = logging.StreamHandler()
        # console_handler.setLevel(logging.INFO)
        console_formatter = logging.Formatter('%(levelname)s: %(message)s')
        console_handler.setFormatter(console_formatter)
        self.logger.addHandler(console_handler)

        # parse command line args
        if self.args is None:
            self.parse_arguments()

        # If Verbose is enabled or logging a file
        if self.args.verbose and not self.args.log_file:
            console_handler.setLevel(logging.DEBUG)

        # If file logging is enabled, log all info to a file
        if self.args.log_file:
            file_handler = logging.FileHandler(self.args.log_file)
            file_handler.setLevel(logging.DEBUG)
            file_formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
            file_handler.setFormatter(file_formatter)
            self.logger.addHandler(file_handler)
    
    def parse_arguments(self)->None:
        """Parse Command Line Args"""
        parser = argparse.ArgumentParser(description="PC BootLoader Script for programming the FPGA MSP430FR6989.")
        parser.add_argument("-p", "--port", required=True, help="Serial Port (e.g. COM3)")
        parser.add_argument("-v", "--verbose", action="store_true", help="Enable verbose output")
        parser.add_argument("-l", "--log-file", nargs = '?', const = "BSL_log.txt", help="Log verbose output to file (default: BSL_log.txt)")
        parser.add_argument("file", help="Path to intel HEX file")
        self.args = parser.parse_args()

    def run(self)->int:
        """Run the Bootloader Process"""
        start_time = time.perf_counter()
        self.logger.info("Starting bootloader process...")
        retVal:int = 0

        # Initialize the HexParser and SerialHandler
        try:
            self.hex_parser = HexParser(self.args.file, self.logger)
        except Exception as e:
            # self.logger.error(f"Error durign Hex Parsing: {e}")
            self.logger.info("Bootloader execution killed due to earlier errors.")
            return 1
        self.serial_handler = SerialHandler(self.args.port, logger=self.logger)

        try:
            # Establish Connection
            self.serial_handler.open_port()
            record:str = self.generateRecord(RECORDS.NOP)
            response:RESPONSE = self.transaction(record)
            self.handleResponse(response)

            # Start BSL
            record = self.generateRecord(RECORDS.BSL_START)
            response = self.transaction(record)
            self.handleResponse(response)

            # Send Each record to Interface, handle response
            count:int = self.hex_parser.get_recordCount()
            for idx, record in enumerate(self.hex_parser.get_records()):
                if self.args.verbose:
                    self.logger.debug(f"Transmitting Data Record {idx+1}/{count}> {record.strip("\r\n ")}")
                elif idx != count-1:
                    self.log_progress(f"Transmitting Data Record {idx+1}/{count}")
                else:
                    self.logger.info(f"Transmitting Data Record {idx+1}/{count}")
                response = self.transaction(record)
                self.handleResponse(response)
            
            # Log information
            self.logger.debug(f"Transmitted {count} records.")
            self.logger.info(f"Device Programmed. {self.hex_parser.get_byteCount()} bytes written.")

            # Log performance time
            elapsed_time = time.perf_counter() - start_time
            self.logger.info(f"Elapsed time: {elapsed_time:.3f} s.")
        
        except serial.SerialException as e:
            self.logger.error(f"Serial Error encountered during script execution: {e}")
            self.logger.info("Bootloader execution killed due to earlier errors.")
            retVal = 1
           
        finally:
            # Close serialHandle
            self.logger.debug("Closing serial port")
            self.serial_handler.close_port()
            return retVal

    def log_progress(self, message:str, level:int = logging.INFO)->None:
        """Log a progress message"""
        self.logger.log(level, message, extra={"use_cr":True})

    def generateRecord(self, type: RECORDS)->str:
        match(type):
            case RECORDS.NOP:
                return ":00000002FE\n"
            case RECORDS.BSL_START:
                return ":00000003FD\n"
            case RECORDS.EOF:
                return ":00000001FF\n"
            case _:
                raise ValueError(f"Cannot produce record of type {type}")

    def transaction(self, record:str)->RESPONSE:
        """Transaction. Send record, receive response, parse response"""
        valid_responses = [RESPONSE.ACK.value, RESPONSE.NO_TARGET.value, 
                           RESPONSE.TRIPLE_NACK.value, RESPONSE.NONE.value]
        try:
            for n in range(3):
                self.logger.debug(f"Transaction attempt {n+1}/3")
                self.serial_handler.send_data(record)
                response = int.from_bytes(self.serial_handler.read_byte())
                if response in valid_responses:
                    return RESPONSE(response)
            else:
                return RESPONSE.TRIPLE_NACK
        except serial.SerialException as e:
            self.logger.error(f"Error during transaction: {e}")
            raise

    def handleResponse(self, response:RESPONSE):
        match(response):
            case RESPONSE.NONE:
                raise serial.SerialException("No Response from Target")
            case RESPONSE.TRIPLE_NACK:
                raise serial.SerialException("Triple NACK from Interface/Target")
            case RESPONSE.NO_TARGET:
                raise serial.SerialException("No Target Detected by Interface")
            case _:
                self.logger.debug(f"Received from device: {response.name}")                                                                                        

if __name__ == "__main__":
    bootloader = Bootloader()
    code = bootloader.run()
    print(f"Bootloader process completed with exit code {code}.")

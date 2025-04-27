from serial import Serial, SerialException
from enum import Enum
import argparse
import os
import sys

DEFAULT_CON = "COM5"
TIMEOUT = 10

RECORD_NOP = ":00000002FE\r\n"
RECORD_BSL_START = ":00000003FD\r\n"

class Config:
    def __init__(self, com_port, filepath):
        self.com_port = com_port
        self.filepath = filepath

    def __repr__(self):
        return f"Config(com_port={self.com_port}, filepath={self.filepath})"

def parse_arguments():
    parser = argparse.ArgumentParser(description="BSL Scripter Argument Parser")
    parser.add_argument("-C", "--com-port", default="COM4", help="COM port (e.g., COMx, defaults to COM4)")
    parser.add_argument("filepath", nargs="?", help="Path to the .hex file")
    
    # Check if no arguments provided after script name
    if len(sys.argv) == 1:
        parser.print_help()
        sys.exit(0)
    
    args = parser.parse_args()
    
    # Validate filepath if provided
    if args.filepath:
        if not os.path.isfile(args.filepath):
            raise argparse.ArgumentError(None, f"File {args.filepath} does not exist")
        if not args.filepath.endswith('.hex'):
            raise argparse.ArgumentError(None, "File must have .hex extension")
    else:
        parser.print_help()
        sys.exit(0)
    
    return Config(args.com_port, args.filepath)

class Response(Enum):
    NONE = 0
    ACK  = 0x10
    NACK = 0x11
    NO_TARGET = 0x20
    TRIPLE_NACK = 0x21

class ResponseError(Exception):
    pass

class ScriptError(Exception):
    pass

def script(con: str, hexPath: str)->None:
    # if con or path dont exist, raise error
    if not con or con.__len__ == 0:
        raise ScriptError(f"Error: Provide a Connection (ie. COM5)")

    if not hexPath or hexPath.__len__ == 0:
        raise ScriptError(f"Error: Provide a source path (ie. Debug/main.hex)")
    
    # Establish Connection with MSP430 Interface
    try:
        ser = Serial(con, baudrate=115200, timeout= TIMEOUT)
    except SerialException as error:
        raise ScriptError(f"Error: Cannot open {con}")
    
    # Connection established, send NOP to test if BSL interface connected
    response = sendRecord(ser, RECORD_NOP)
    error = parseResponse(response)
    if error:
        raise error
            
    # Connected to Valid BSL Interface. Send BSL Start Sequence
    response = sendRecord(ser, RECORD_BSL_START)
    error = parseResponse(response)
    if error:
        raise error

    # BSL Start Sequence Completed. Send HEX File. 
    # Final line reads EOF. Triggers Target Reset
    with open(hexPath, 'r') as file:
        for record in file:
            response = sendRecord(ser, record)
            error = parseResponse(response)
            if error:
                file.close()
                raise error

    # Close connection
    ser.close()
    return

def parseResponse(response: Response)->ResponseError:
    match response:
        case Response.ACK:
            error = None
        case Response.NACK:
            error = None
        case Response.NO_TARGET:
            error = ResponseError("Response Error: No Target Detected")
        case Response.TRIPLE_NACK:
            error = ResponseError("Response Error: Triple NACK")
        case Response.NONE:
            error = ResponseError("Response Error: No Response from Interface")
        case _:
            error = ResponseError(f"Response Error: Invalid Response {response}")
    return error


def sendRecord(ser:Serial, rec: str)->Response:
    if not ser.is_open or not rec or rec.__len__ == 0:
        return Response.NONE
    
    if rec[-1] != '\r' and rec[-1] != '\n':
        rec = rec + '\r'

    # Send Record 3 times, wait for response
    for _ in range(3):
        ser.write(rec.encode())
        resp = int.from_bytes(ser.read())

        if resp is not None and resp != Response.NACK:
            return Response(resp)
    
    return Response.TRIPLE_NACK
    
    


def main()->None:
    config = parse_arguments()
    try:
        script(con = config.com_port, hexPath = config.filepath)
        print("Target Device Programmed.")
    except ResponseError as error:
        print(error)
    except ScriptError as error:
        print(error)

if __name__ == "__main__":
    main()
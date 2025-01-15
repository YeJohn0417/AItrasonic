import sys
import os
import glob


class FileReader:
    def __init__(self, filename):
        self.filename = filename

    def open(self):
        print("Reading file ", self.filename)
        try:
            self.file = open(self.filename, 'r')
        except OSError:
            print("Cannot open file ", self.filename)
            sys.exit(-1)
        return self.file

    def get_filename(self):
        return self.filename

    def close(self):
        if hasattr(self, 'file'):
            self.file.close()
            self.__del__()


class FileWriter:
    def __init__(self, filename):
        self.filename = filename

    def open(self):
        print("Writing to file ", self.filename)
        try:
            self.file = open(self.filename, 'wb')
        except OSError:
            print("Cannot open file ", self.filename)
            sys.exit(-1)
        return self.file

    def get_filename(self):
        return self.filename

    def close(self):
        if hasattr(self, 'file'):
            self.file.close()
            self.__del__()

if __name__ == "__main__":

    BYTE_ZERO = "00"

    input_folder = "./model_parameters_quantized_hex"
    output_folder = "./model_parameters_quantized_hex_bin"

    # Convert .hex
    if not os.path.exists(output_folder):
        os.makedirs(output_folder)

    hex_files = glob.glob(os.path.join(input_folder, "*.hex"))

    for ifname in hex_files:
        ifname_prefix = os.path.splitext(os.path.basename(ifname))[0]
        ofname = os.path.join(output_folder, ifname_prefix + ".dat")
        rf = FileReader(ifname).open()
        wf = FileWriter(ofname).open()
        lines = rf.readlines()
        for l in lines:
            line = l.rstrip("\n")
            wb = bytearray.fromhex(BYTE_ZERO + BYTE_ZERO + BYTE_ZERO + line)
            wb.reverse()
            wf.write(wb)
        rf.close()
        wf.close()

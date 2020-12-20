from enum import Enum


class Type(Enum):
    IMM = 0         //  [op | 4 bit] [imm | 5 bit]
    REG = 1         //  [op | 4 bit] [reg | 3 bit] [funct | 2 bit]
    SHIFT = 2       //  [op | 4 bit] [reg | 3 bit] [immed | 2 bit]
    OTHER = 3       //  [op | 4 bit] [xxxxx]

instrType = {"load" : Type.REG, "store" : Type.REG, "shiftl" : Type.SHIFT, "shiftr" : Type.SHIFT,
             "add" : Type.REG, "addc" : Type.REG, "sub" : Type.REG, "subc" : Type.REG,
             "or" : Type.REG, "and" : Type.REG, "xor" : Type.REG, "nand" : Type.REG,
             "cmpe" : Type.REG, "cmpg" : Type.REG, "cmpl" : Type.REG, "bne" : Type.IMM,
             "beq" : Type.IMM, "jump" : Type.IMM, "loadi" : Type.IMM, "movi" : Type.REG,
             "movo" : Type.REG, "swap" : Type.REG, "shiftlc" : Type.REG, "shiftrc" : Type.REG,
             "addi" : Type.SHIFT, "subi" : Type.SHIFT, "halt" : Type.OTHER}

instrOpcode = {"load" : "0000", "store" : "0001", "shiftl" : "0010", "shiftr" : "0011",
               "add" : "0100", "addc" : "0100", "sub" : "0100", "subc" : "0100",
               "or" : "0101", "and" : "0101", "xor" : "0101", "nand" : "0101",
               "cmpe" : "0110", "cmpg" : "0110", "cmpl" : "0110", "bne" : "0111",
               "beq" : "1000", "jump" : "1001", "loadi" : "1010", "movi" : "1011",
               "movo" : "1011", "swap" : "1011", "shiftlc" : "1100", "shiftrc" : "1100",
               "addi" : "1101", "subi" : "1110", "halt" : "1111"}

instrFunct =   {"add" : "00", "addc" : "01", "sub" : "10", "subc" : "11",
                "or" : "00", "and" : "01", "xor" : "10", "nand" : "11",
                "cmpe" : "00", "cmpg" : "01", "cmpl" : "10",
                "movi" : "00", "movo" : "01", "swap" : "10",
                "shiftlc" : "00", "shiftrc" : "01"}

register = {"r0" : "000", "r1" : "001", "r2" : "010", "r3" : "011", "r4" : "100", "r5" : "101", "r6" : "110", "r7" : "111"}

branchMap = list()
branchInstr = list()

def readFile(path, out):
    file = open(path, "r")
    outfile = open(out, 'w') 
    
    lineNum = 0
    # Iterate file to construct branch map
    for l in file:
        if ":" in l:
            i = l.find(':', 0)
            if l[:i] not in branchMap:
                branchMap.append(l[:i])
                branchInstr.append(lineNum)
            else:
                pass
        elif l != "\n":
            lineNum += 1
    # Convert instruction into 9 bit representation
    file.seek(0)
    bits = ""
    for l in file:
        if ":" in l or l == "\n":
            continue
        else:
            l = l.strip('\n')
            l = l.strip('\t')
            instr = l.split()
            op = instrOpcode[instr[0]]
            
            if (instrType[instr[0]] == Type.IMM):
                if (instr[0] == "beq" or instr[0] == "bne" or instr[0] == "jump"):
                    toReplace = op +"{0:05b}".format(branchMap.index(instr[1]))
                else:
                    toReplace = op + "{0:05b}".format(int(instr[1]))
            elif (instrType[instr[0]] == Type.REG):
                toReplace = op + register[instr[1]] + instrFunct.get(instr[0], "00")
            elif (instrType[instr[0]] == Type.SHIFT):
                toReplace = op + register[instr[1]] + "{0:02b}".format( int(instr[2]) - 1 )
            elif (instrType[instr[0]] == Type.OTHER):
                toReplace = op + "00000"
            else: 
                pass
            outfile.write(toReplace + "\n")
            bits += toReplace
    # outfile.write(int(bits, 2).to_bytes((len(bits) +7)//8, byteorder="big"))
    file.close()
    outfile.close()

    for i in range(len(branchMap)):
        print(str(branchMap[i]) + " : " + str(branchInstr[i]))

def makeLUT():
    outfile = open("LUT.v", 'w')
    lines = ["// Module Name:    LUT\n",
             "// Project Name:   CSE141L\n",
             "//\n",
             "// Revision Fall 2020\n",
             "// Based on SystemVerilog source code provided by John Eldon\n",
             "// Comment:\n",
             "// This is the lookup table\n",
             "// Leverage a few-bit pointer to a wider number\n",
             "// It is optional\n",
             "// You may increase the Addr, but you are not allowed to go over 32 elements (5 bits)\n",
             "// You could use it for anything you want. Ex. possible lookup table for PC target\n",
             "// Lookup table acts like a function: here Target = f(Addr);\n",
             "//  in general, Output = f(Input);\n",
             "module LUT(Addr, Target);\n",
             "\tinput\t[ 4:0] Addr;\n",
             "\toutput reg\t[ 10:0] Target;\n",
             "\n",
             "\talways @*\n",
             "\t\tcase(Addr)\n"]
             
    for i in range(len(branchMap)):
        line = "\t\t\t5'b"
        line = line + "{0:05b}".format(i) + ":\tTarget = 11'd" + str(branchInstr[i]) + ";\n"
        lines.append(line)
    lines.append("\t\t\tdefault:\tTarget = 11'h000;\n")    
    lines.append("\t\tendcase\n")
    lines.append("endmodule\n")
    outfile.writelines(lines)
    outfile.close()

def makeROM(out):
    outfile = open("InstROM.v", 'w')
    lines = ["module InstROM (InstAddress, InstOut) ;\n",
             "\tinput [11-1:0] InstAddress;\n",
             "\toutput reg[8:0] InstOut;\n",
             "\treg[8:0] inst_rom[(2**11)-1:0];\n",
             "\talways@* InstOut = inst_rom[InstAddress];\n",
             "\tinitial begin\n"]
    lines.append("\t\t$readmemb(\"" + out + "\",inst_rom);\n")
    lines.append("\tend\n")
    lines.append("endmodule\n")
    outfile.writelines(lines)
    outfile.close()

program = input("Enter p1 for program 1, p2 for program 2, or p3 for program 3: ")
if program == 'p1':
    filename = 'program1.txt'
    outfile = 'machine_codeP1.txt'
elif program == 'p2':
    filename = 'program2.txt'
    outfile = 'machine_codeP2.txt'
elif program == 'p3':
    filename = 'program3.txt'
    outfile = 'machine_codeP3.txt'
else:
    print('Invalid input')
    exit()

readFile(filename, outfile)
makeLUT()
makeROM(outfile)
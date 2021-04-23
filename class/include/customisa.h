//////////////////////////////////////////////////////////////////////////////
//
//    CLASS - Cloud Loader and ASsembler System
//    Copyright (C) 2021 Winor Chen
//
//    This program is free software; you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation; either version 2 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License along
//    with this program; if not, write to the Free Software Foundation, Inc.,
//    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
//
//////////////////////////////////////////////////////////////////////////////
#ifndef __CUSTOMISA_H__
#define __CUSTOMISA_H__


/* A header for mips specifc details
 * such as register name mappings
 * and a jump list for functional routines
 *
 * Instruction Formats:
 * R - 6 opcode, 5 rs, 5 rt, 5 rd, 5 shamt, 6 funct
 * I - 6 opcode, 5 rs, 5 rt, 16 imm
 * J - 6 opcode, 26 addr
 *
 *
 * wchen329
 */
#include <cstring>
#include <cstddef>
#include <memory>
#include "ISA.h"
#include "mt_exception.h"
#include "primitives.h"
#include "priscas_global.h"
#include "syms_table.h"
#include "ustrop.h"

namespace priscas
{

	// Friendly Register Names -> Numerical Assignments
	enum REGISTERS
	{
		$r0 = 0,
		$r1 = 1,
		$r2 = 2,
		$r3 = 3,
		$r4 = 4,
		$r5 = 5,
		$r6 = 6,
		$r7 = 7,
		$r8 = 8,
		$r9 = 9,
		$r10 = 10,
		$r11 = 11,
		$r12 = 12,
		$r13 = 13,
		$r14 = 14,
		$r15 = 15,
		$r16 = 16,
		$r17 = 17,
		$r18 = 18,
		$r19 = 19,
		$r20 = 20,
		$r21 = 21,
		$r22 = 22,
		$r23 = 23,
		$r24 = 24,
		$r25 = 25,
		$r26 = 26,
		$r27 = 27,
		$r28 = 28,
		$r29 = 29,
		$lr = 30,
		$ilr = 31,
		INVALID = -1
	};

	// // instruction formats
	// enum format
	// {
	// 	R, I, J	
	// };

	// MIPS Processor Opcodes
	enum opcode
	{
		ADD = 0,
		ADDI = 1,
		SUB = 2,
		SUBI = 3,
		RSHFTL = 4,
		RSHFTA = 5,
		LSFHT = 6,
		AND = 7,
		OR =  8,
		NOT = 9,
		// SLTI = 10,
		// SLTIU = 11,
		MOV = 12,
		LD = 13,
		ST = 14,
		PUSH = 15,
        POP = 16,
        B = 17,
        BEQ = 18,
        JMP = 19,
        FUN = 20,
        RET = 21,
        INTR = 22,
        NOP = 25,
        HALT = 31,
		// LB = 32,
		// LH = 33,
		// LWL = 34,
		// LW = 35,
		// LBU = 36,
		// LHU = 37,
		// LWR = 38,
		// SB = 40,
		// SH = 41,
		// SWL = 42,
		// SW = 43,
		SYS_RES = -1	// system reserved for shell interpreter
	};

	// Function codes for R-Format Instructions
	// enum funct
	// {
	// 	SLL = 0,
	// 	SRL = 2,
	// 	JR = 8,
	// 	ADD = 32,
	// 	ADDU = 33,
	// 	SUB = 34,
	// 	SUBU = 35,
	// 	AND = 36,
	// 	OR = 37,
	// 	NOR = 39,
	// 	SLT = 42,
	// 	SLTU = 43,
	// 	NONE = -1	// default, if not R format
	// };

	int regname_to_numerical(const char *);

	// From a register specifier, i.e. %so get an integer representation
	int get_reg_num(const char *);

	// From a immediate string, get an immediate value.
	int get_imm(const char *);

	// namespace ALU
	// {
	// 	enum ALUOp
	// 	{
	// 				ADD = 0,
	// 				SUB = 1,
	// 				SLL = 2,
	// 				SRL = 3,
	// 				OR = 4,
	// 				AND = 5,
	// 				XOR = 6
	// 	};
	// }

	// // Format check functions
	// /* Checks if an instruction is I formatted.
	//  */
	// bool i_inst(opcode operation);

	// /* Checks if an instruction is R formatted.
	//  */
	// bool r_inst(opcode operation);

	// /* Checks if an instruction is J formatted.
	//  */
	// bool j_inst(opcode operation);

	// /* Checks if an instruction performs
	//  * memory access
	//  */
	// bool mem_inst(opcode operation);

	// /* Checks if an instruction performs
	//  * memory write
	//  */
	// bool mem_write_inst(opcode operation);

	// /* Checks if an instruction performs
	//  * memory read
	//  */
	// bool mem_read_inst(opcode operation);

	// /* Checks if an instruction performs
	//  * a register write
	//  */
	// bool reg_write_inst(opcode operation, funct func);

	// /* Check if a special R-format
	//  * shift instruction
	//  */
	// bool shift_inst(funct f);

	// /* Check if a Jump or
	//  * Branch Instruction
	//  */
	// bool jorb_inst(opcode operation, funct fcode);

	/* "Generic" MIPS-32 architecture
	 * encoding function asm -> binary
	 */
	BW_32 generic_mips32_encode(int rs, int rt, int rd, int funct, int imm_shamt_jaddr, opcode op);

	/* For calculating a label offset in branches
	 */
	BW_32 offset_to_address_br(BW_32 current, BW_32 target);

	/* MIPS_32 ISA
	 *
	 */
	class customisa : public ISA
	{
		
		public:
			virtual std::string get_reg_name(int id);
			virtual int get_reg_id(std::string& fr) { return regname_to_numerical(fr.c_str()); }
			virtual ISA_Attrib::endian get_endian() { return ISA_Attrib::CPU_LITTLE_ENDIAN; }
			virtual mBW assemble(const Arg_Vec& args, const BW& baseAddress, syms_table& jump_syms) const;
		private:
			static const unsigned REG_COUNT = 32;
			static const unsigned PC_BIT_WIDTH = 32;
			static const unsigned UNIVERSAL_REG_BW = 32;
	};
}

#endif

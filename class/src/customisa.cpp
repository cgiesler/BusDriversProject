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
#include "customisa.h"
// #include <string>

namespace priscas
{
	int regname_to_numerical(const char * fr_name)
	{
		int len = strlen(fr_name);
		if(len < 2) return INVALID;
        const char * temp = &fr_name[2];

		int reg_val = 
            !strcmp("$lr", fr_name) ? $lr :
            !strcmp("$ilr", fr_name) ? $ilr :
            std::stoi(temp);
		return reg_val;
	}

	std::string customisa::get_reg_name(int id)
	{
		std::string name =
			id == 0 ? "$r0" :
			id == 1 ? "$r1" :
			id == 2 ? "$r2" :
			id == 3 ? "$r3" :
			id == 4 ? "$r4" :
			id == 5 ? "$r5" :
			id == 6 ? "$r6" :
			id == 7 ? "$r7" :
			id == 8 ? "$r8" :
			id == 9 ? "$r9" :
			id == 10 ? "$r10" :
			id == 11 ? "$r11" :
			id == 12 ? "$r12" :
			id == 13 ? "$r13" :
			id == 14 ? "$r14" :
			id == 15 ? "$r15" :
			id == 16 ? "$r16" :
			id == 17 ? "$r17" :
			id == 18 ? "$r18" :
			id == 19 ? "$r19" :
			id == 20 ? "$r20" :
			id == 21 ? "$r21" :
			id == 22 ? "$r22" :
			id == 23 ? "$r23" :
			id == 24 ? "$r24" :
			id == 25 ? "$r25" :
			id == 26 ? "$r26" :
			id == 27 ? "$r27" :
			id == 28 ? "$r28" :
			id == 29 ? "$r29" :
			id == 30 ? "$lr" :
			id == 31 ? "$ilr" : "";
		
		if(name == "")
		{
			throw reg_oob_exception();
		}
		
		return name;
	}

    bool inst_3operands(opcode operation)
    {
        return 
            operation == NOT ? true :
            operation == MOV ? true :
            false;
    }

    bool inst_2operands(opcode operation)
    {
        return 
            operation == JMP ? true :
            operation == PUSH ? true :
            operation == POP ? true :
            operation == FUN ? true :
            false;
    }

    bool inst_1operands(opcode operation)
    {
        return 
            operation == RET ? true :
            operation == INTR ? true :
            operation == HALT ? true :
            false;
    }

	BW_32 generic_customisa_encode(int rx, int ry, int rz, int imm, opcode op)
	{
		BW_32 w = 0;
        if (op >= 0) w = (w.AsUInt32() | ((op & ((1 << 5) - 1) ) << 27 ));
        if (rx >= 0) w = (w.AsUInt32() | ((rx & ((1 << 5) - 1) ) << 22 ));
        if (ry >= 0) w = (w.AsUInt32() | ((ry & ((1 << 5) - 1) ) << 17 ));
        if (rz >= 0) w = (w.AsUInt32() | ((rz & ((1 << 5) - 1) ) << 12 ));
        if (imm >= 0)
            if (rx >= 0 && ry >= 0 && rz <= 0) w = (w.AsUInt32() | (imm & ((1 << 17) - 1)));
            else if (rx >= 0 && ry <= 0 && rz <= 0) w = (w.AsUInt32() | (imm & ((1 << 22) - 1)));
            else if (rx <= 0 && ry <= 0 && rz <= 0) w = (w.AsUInt32() | (imm & ((1 << 27) - 1)));
		return w;
	}

	BW_32 offset_to_address_br(BW_32 current, BW_32 target)
	{
		BW_32 ret = target.AsUInt32() - current.AsUInt32();
		ret = ret.AsUInt32() - 4;
		ret = (ret.AsUInt32() >> 2);
		return ret;
	}

	// Main interpretation routine
	mBW customisa::assemble(const Arg_Vec& args, const BW& baseAddress, syms_table& jump_syms) const
	{
		if(args.size() < 1)
			return std::shared_ptr<BW>(new BW_32());
        
        // printf("starting");

		priscas::opcode current_op = priscas::SYS_RES;
		// priscas::funct f_code = priscas::NONE;

		int rx = -1;
		int ry = -1;
		int rz = -1;
		int imm = -1;

		// Mnemonic resolution
		
		if("add" == args[0]) { current_op = priscas::ADD;}
		else if("addi" == args[0]) { current_op = priscas::ADDI;}
		else if("sub" == args[0]) { current_op = priscas::SUB;}
		else if("subi" == args[0]) { current_op = priscas::SUBI;}
		else if("rshftl" == args[0]) { current_op = priscas::RSHFTL;}
        else if("rshfta" == args[0]) { current_op = priscas::RSHFTA;}
		else if("lshft" == args[0]) { current_op = priscas::LSFHT;}
		else if("and" == args[0]) { current_op = priscas::AND;}
		else if("or" == args[0]) { current_op = priscas::OR;}	
		else if("not" == args[0]) { current_op = priscas::NOT; }	
		else if("mov" == args[0]) { current_op = priscas::MOV;}	
		else if("ld" ==  args[0]) { current_op = priscas::LD; }
		else if("st" == args[0]) { current_op = priscas::ST; }
		else if("push" == args[0]) { current_op = priscas::PUSH; }
		else if("pop" == args[0]) { current_op = priscas::POP; }
		else if("b" == args[0]) { current_op = priscas::B; }
		else if("beq" == args[0]) { current_op = priscas::BEQ; }
		else if("jmp" == args[0]) { current_op = priscas::JMP; }
		else if("fun" == args[0]) { current_op = priscas::FUN;}
		else if("ret" == args[0]) { current_op = priscas::RET;}
		else if("intr" == args[0]) { current_op = priscas::INTR;}
        else if("nop" == args[0]) { current_op = priscas::NOP;}		
		else if("halt" == args[0]) { current_op = priscas::HALT;}
		else
		{
			throw mt_bad_mnemonic();
		}

		// Check for insufficient arguments
		if(args.size() > 1)
		{
			if	(
					(inst_1operands(current_op) && args.size() != 1) ||
					(inst_2operands(current_op) && args.size() != 2) ||
					(inst_3operands(current_op) && args.size() != 3)	
				)
			{
                // printf("%s | %s", current_op, args.size());
				throw priscas::mt_asm_bad_arg_count();
			}
            else if (args.size() != 4 && !inst_1operands(current_op) && !inst_2operands(current_op) && !inst_3operands(current_op)) {
                throw priscas::mt_asm_bad_arg_count();
            }
			// Now first argument parsing
            if (current_op == JMP || current_op == FUN) {
                if(jump_syms.has(args[1]))
				{
                    priscas::BW_32 addr = baseAddress.AsUInt32();
					priscas::BW_32 label_PC = static_cast<int32_t>(jump_syms.lookup_from_sym(std::string(args[1].c_str())));
					imm = priscas::offset_to_address_br(addr, label_PC).AsUInt32();
				}
				else
				{
					imm = priscas::get_imm(args[1].c_str());
				}
            }
            else if (current_op != JMP) rx = priscas::get_reg_num(args[1].c_str());
			else
			{
				priscas::mt_bad_mnemonic();
			} 
		}
        // printf("%s", "first done");
		// Second Argument Parsing
		
		if(args.size() > 2)
		{
            if (current_op == FUN || current_op == MOV) {
                if(jump_syms.has(args[2]))
				{
					priscas::BW_32 label_PC = static_cast<int32_t>(jump_syms.lookup_from_sym(std::string(args[2].c_str())));
					imm = label_PC.AsUInt32();
				}
				else
				{
					imm = priscas::get_imm(args[2].c_str());
				}
                if (current_op == FUN) rx = priscas::$lr;
            }
            else ry = priscas::get_reg_num(args[2].c_str());
		}
        // printf("%s", "second done");

		if(args.size() > 3)
		{
            // Third Argument Parsing
            if (jump_syms.has(args[3]))
            {
                priscas::BW_32 addr = baseAddress.AsUInt32();
                priscas::BW_32 label_PC = static_cast<uint32_t>(jump_syms.lookup_from_sym(std::string(args[3].c_str())));
                imm = priscas::offset_to_address_br(addr, label_PC).AsUInt32();
            }
            else if (current_op == SUB || current_op == ADD || current_op == AND || current_op == OR) {
                rz = priscas::get_reg_num(args[3].c_str());
            }
            else {
                imm = priscas::get_imm(args[3].c_str());
            }
		}
        // printf("%s", "third done");

		// Pass the values of rs, rt, rd to the processor's encoding function
		BW_32 inst = generic_customisa_encode(rx, ry, rz, imm, current_op);

		return std::shared_ptr<BW>(new BW_32(inst));
	}

	// Returns register number corresponding with argument if any
	// Returns -1 if invalid or out of range
	int get_reg_num(const char * reg_str)
	{
        int len = strlen(reg_str);
		if(len < 2) return INVALID;
        const char * temp = &reg_str[2];

		int reg_val = 
            !strcmp("$lr", reg_str) ? $lr :
            !strcmp("$ilr", reg_str) ? $ilr :
            std::stoi(temp);
		return reg_val;
	}

	// Returns immediate value if valid
	int get_imm(const char * str)
	{
		return StrOp::StrToUInt32(UPString(str));
	}
}

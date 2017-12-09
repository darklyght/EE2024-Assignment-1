 	.syntax unified
 	.cpu cortex-m3
 	.thumb
 	.align 2
 	.global	distrBF
 	.thumb_func

@ EE2024 Assignment 1, Sem 1, AY 2017/18
@ (c) CK Tham, ECE NUS, 2017

@ Kat Li Yang A0155439X
@ Ang Zhi Yuan A0150120H

// R0 -> T / T countdown
// R1 -> Pointer to dij
// R2 -> Pointer to Dj
// R3 -> Pointer to result
// R4 -> N
// R5 -> N countdown / RETRIEVE N index
// R6 -> Input array pointer for RETRIEVE
// R7 -> Output value for RETRIEVE
// R8 -> Accumulate dij and Dj
// R9 -> Current minimum
// R10 -> Current minimum index
// R11 ->
// R12 ->

distrBF:
	PUSH {R4-R10, R14}
	LDR R4, [R3] // Save value of N
	ADD R3, R3, R0, LSL #3 // Move R3 to point to the end of the results array
	SUB R0, #1 // Change T counter from 1-based index to 0-based index
	TLOOP:
		MOV R5, R4 // Initialise N count to N
		SUB R5, #1 // Change N counter from 1-based index to 0-based index
		MVN R9, #0x80000000 // Initialise minimum to #0x7FFFFFFF (highest signed int), #0x80000000 is #1, LSL #31 => #0x80000000 is op2
		NLOOP:
			MOV R6, R1 // Set input array address for RETRIEVE to dij pointer
			BL RETRIEVE // Retrieve (T count, N count) from dij
			MOV R8, R7 // Move output to accumulator register R8
			MOV R6, R2 // Set input array pointer for RETRIEVE to Dj pointer
			BL RETRIEVE // Retrieve (T count, N count) from Dj
			ADD R8, R7 // Accumulate output in accumulator register R8
			CMP R8, R9 // (dij + Dj) - (current minimum)
			ITT MI // (dij + Dj) - (current minimum) < 0 => (dij + Dj) is new minimum
				MOVMI R9, R8 // Set current minimum to (dij + Dj)
				MOVMI R10, R5 // Set current minimum index to N count
			SUBS R5, #1 // Decrement N count
			BPL NLOOP // (N count) >= 0, repeat NLOOP for next N count in current T count
		ADD R10, #1 // Change minimum index from 0-based index to 1-based index
		STMDB R3!, {R9, R10} // Store multiple and decrement before current minimum and minimum index
		SUBS R0, #1 // Decrement T count
		BPL TLOOP // (T count) >= 0, repeat TLOOP for next T count
	POP {R4-R10, R14}
	BX	LR

@ Subroutine RETRIEVE
RETRIEVE:
	// Input:
	// R0 -> Row (0-based index)
	// R4 -> Total columns
	// R5 -> Column (0-based index)
	// R6 -> Array to access
	// Output:
	// R7 -> Value in array R6 at (R0, R5)
	MLA R7, R0, R4, R5 // Multiply row by total columns and add column
	LDR R7, [R6, R7, LSL #2] // Multiply overall index by 4 for address offset and put contents into output with offset
	BX LR

	NOP
	.end

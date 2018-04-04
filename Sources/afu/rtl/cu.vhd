library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.STD_LOGIC_UNSIGNED.ALL;

library work;
  use work.functions.all;
  use work.psl.all;
  use work.cu_package.all;
  use work.dma_package.all;

entity cu is
  port (
    i                       : in  cu_in;
    o                       : out cu_out
  );
end entity cu;

architecture logic of cu is

component matix_mul
port(
	clk		:in std_logic;
	rst		:in std_logic;
	start		:in std_logic;	
	data		:in std_logic_vector(1023 downto 0);
	size1		:in std_logic_vector(63 downto 0);
	size2		:in std_logic_vector(63 downto 0);
	valid		:in std_logic;
	data_out	:out std_logic_vector(1023 downto 0);
	pull		:in std_logic;
	empty		:out std_logic;
	finish		:out std_logic;
	full		:out std_logic
);
end component;
  signal rdaddress1,wraddress1: unsigned(255 downto 0);
  signal rdaddress2,wraddress2: unsigned(255 downto 0);
  signal q, r               : cu_int;
  signal re                 : cu_ext;
  signal mm_finish	    	: std_logic;
  signal matrix_cnt			: std_logic_vector(31 downto 0);
  signal wed_backup			: cu_int;
  signal finish_flag		: std_logic;
begin

  comb : process(all)
    variable v              : cu_int;
	variable rdaddress,wraddress: unsigned(255 downto 0);
  begin

----------------------------------------------------------------------------------------------------------------------- default assignments

    v                       := r;
    v.pull                  := '0';
    v.o.read.valid          := '0';
    v.o.write.request.valid := '0';
    v.o.write.data.valid    := '0';

----------------------------------------------------------------------------------------------------------------------- state machine

    case r.state is
      when idle =>
        if i.start then
          v.state           := read_write;
          v.wed             := i.wed;
          v.o.done          := '0';
		  wraddress(255 downto 192)		:= 	q.wed.destination;
		  rdaddress(255 downto 192)		:= 	q.wed.source;
		  rdaddress(191 downto 128)		:=	unsigned(i.wed.wed07);
		  wraddress(191 downto 128)		:=	unsigned(i.wed.wed08);
		  rdaddress(127 downto 64)		:=	unsigned(i.wed.wed09);
		  wraddress(127 downto 64)		:=	unsigned(i.wed.wed10);
		  rdaddress(63 downto 0)		:=	unsigned(i.wed.wed11);
		  wraddress(63 downto 0)		:=	unsigned(i.wed.wed12);
        end if;
	
	  when read_write =>
		read_cachelines   (v.o.read, 			rdaddress2(255 downto 192), 		unsigned(q.wed.wed04(31 downto 0)) );
		write_cachelines  (v.o.write.request, 	wraddress2(255 downto 192), 		q.wed.size);
		wraddress(255 downto 64)		:= 	wraddress2(191 downto 0);
		rdaddress(255 downto 64)		:= 	rdaddress2(191 downto 0);
		v.state				:=calculate;
		
      when calculate =>
        if not(re.fifo.empty) and not(i.write.full(0)) then
          v.pull            := '1';
          write_data        (v.o.write.data, re.fifo.data);
        end if;
		wraddress(255 downto 0)		:= 	wraddress2(255 downto 0);
		rdaddress(255 downto 0)		:= 	rdaddress2(255 downto 0);
        v.wed.size          := r.wed.size - u(i.write.valid);
		if v.wed.size = 0 then
			if q.wed.wed06(31 downto 0)= matrix_cnt then
				v.state         := done;
			else
				v.state			:= read_write;
			end if;
        end if;
        --if mm_finish = '1' then
        --  v.state           := done;
		--  v.wed.size        :=X"0000_0000";
        --end if;

      when done =>
        v.o.done            := '1';
        v.state             := idle;

      when others => null;
    end case;

----------------------------------------------------------------------------------------------------------------------- outputs
	
	wraddress1				<=wraddress;
	rdaddress1				<=rdaddress;
    -- drive input registers
    q                       <= v;

    -- outputs
    o                       <= r.o;

  end process;



mm0:matix_mul
port map(
	clk		=> i.cr.clk,
	rst		=> i.cr.rst ,
	start	=> (i.start or finish_flag),
	data	=> i.read.data,
	size1	=> i.wed.wed03,
	size2	=> i.wed.wed05,
	valid	=> i.read.valid,
	data_out=> re.fifo.data,
	pull	=> q.pull,
	empty	=> re.fifo.empty,
	finish  => mm_finish,
	full	=> re.fifo.full
);


----------------------------------------------------------------------------------------------------------------------- fifo

--  fifo0 : entity work.fifo generic map (DMA_DATA_WIDTH, 8, '1', 0)
--    port map (
--      cr.clk                => i.cr.clk,
--      cr.rst                => i.start,
--      put                   => i.read.valid,
--      data_in               => i.read.data,
--      pull                  => q.pull,
--      data_out              => re.fifo.data,
--      empty                 => re.fifo.empty,
--      full                  => re.fifo.full
--    );

----------------------------------------------------------------------------------------------------------------------- reset & registers

  reg : process(i.cr)
  variable output_finish : std_logic;
  begin
	if (r.wed.size - u(i.write.valid)) = 0 then
		output_finish:='1';
	else 
		output_finish:='0';
	end if;
	
    if rising_edge(i.cr.clk) then
		wraddress2				<=wraddress1;
		rdaddress2				<=rdaddress1;
		if (r.wed.size - u(i.write.valid)) = 0 then
			finish_flag<='1';
		else 
			finish_flag<='0';
		end if;
		
		if(i.start) then
			wed_backup.wed<=i.wed;
		end if;
		
		if i.cr.rst then
			matrix_cnt<=x"00000000";
		end if;
	
		if ((r.wed.size - u(i.write.valid)) = 0) then
			matrix_cnt	<=	matrix_cnt + "1";
		end if;
		
		if (i.cr.rst) then
			cu_reset(r);
		else
			if(output_finish) then
				r.state<=q.state;
				r.wed<=wed_backup.wed;
				r.o<=q.o;
				r.pull<=q.pull;
			else
				r <= q;
			end if;
      end if;
    end if;
  end process;

end architecture logic;

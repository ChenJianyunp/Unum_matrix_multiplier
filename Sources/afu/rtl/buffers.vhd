library ieee;
  use ieee.std_logic_1164.all;

library work;
  use work.psl.all;
  use work.functions.all;
  use work.frame_package.all;

entity inbuf is
  port(
    i : in frame_in;
    o : out frame_in
  );
end entity inbuf;

architecture behavioral of inbuf is
begin
  clk_proc: process(i.j.pclock)
  begin
    if rising_edge(i.j.pclock) then
      o.b     <= i.b;
      o.r     <= i.r;
      o.mm    <= i.mm;
      o.j.val <= i.j.val;
      o.j.com <= i.j.com;
      o.j.ea  <= i.j.ea;
    end if;
  end process;
  o.j.pclock <= i.j.pclock;
end architecture behavioral;

-------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;

library work;
  use work.psl.all;
  use work.functions.all;
  use work.frame_package.all;

entity outbuf is
  port(
    clk : in std_logic;
    i   : in frame_out;
    o   : out frame_out
  );
end entity outbuf;

architecture behavioral of outbuf is
begin
  clk_proc: process(clk)
  begin
    if rising_edge(clk) then
      o <= i;
    end if;
  end process;
end architecture behavioral;

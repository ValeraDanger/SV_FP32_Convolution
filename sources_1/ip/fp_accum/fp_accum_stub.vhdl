-- Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2019.1 (win64) Build 2552052 Fri May 24 14:49:42 MDT 2019
-- Date        : Sun Sep 29 14:13:28 2024
-- Host        : DESKTOP-65AD5QT running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub -rename_top fp_accum -prefix
--               fp_accum_ floating_point_0_stub.vhdl
-- Design      : floating_point_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7k325tffg676-3
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity fp_accum is
  Port ( 
    aclk : in STD_LOGIC;
    s_axis_a_tvalid : in STD_LOGIC;
    s_axis_a_tready : out STD_LOGIC;
    s_axis_a_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axis_a_tlast : in STD_LOGIC;
    m_axis_result_tvalid : out STD_LOGIC;
    m_axis_result_tready : in STD_LOGIC;
    m_axis_result_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axis_result_tlast : out STD_LOGIC
  );

end fp_accum;

architecture stub of fp_accum is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "aclk,s_axis_a_tvalid,s_axis_a_tready,s_axis_a_tdata[31:0],s_axis_a_tlast,m_axis_result_tvalid,m_axis_result_tready,m_axis_result_tdata[31:0],m_axis_result_tlast";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "floating_point_v7_1_8,Vivado 2019.1";
begin
end;

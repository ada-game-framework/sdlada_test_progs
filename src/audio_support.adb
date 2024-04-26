--------------------------------------------------------------------------------------------------------------------
--  This source code is subject to the Zlib license, see the LICENCE file in the root of this directory.
--------------------------------------------------------------------------------------------------------------------
package body Audio_Support is

   procedure Callback
     (User   : in Audio_Devices.User_Data_Access;
      Buffer : out Buffer_Type)
   is
      UD : constant Support_User_Data_Access := Support_User_Data_Access (User);
   begin
      for BI in Buffer'Range loop
         Buffer (BI) := Pulse_Frames (UD.State);
         UD.Frame_Count := UD.Frame_Count + 1;
         if UD.Frame_Count = 100 then
            UD.State := (if UD.State = High then Low else High);
            UD.Frame_Count := 0;
         end if;
      end loop;
   end Callback;

end Audio_Support;

--------------------------------------------------------------------------------------------------------------------
--  This source code is subject to the Zlib license, see the LICENCE file in the root of this directory.
--------------------------------------------------------------------------------------------------------------------
with SDL;
with SDL.Log;
with SDL.Timers;

procedure Timers is
   function Ticks return String is
     (SDL.Timers.Milliseconds'Image (SDL.Timers.Ticks));
begin
   SDL.Log.Set (Category => SDL.Log.Application, Priority => SDL.Log.Debug);
   SDL.Log.Put_Debug ("Ticks: " & Ticks);
   SDL.Timers.Wait_Delay (SDL.Timers.Milliseconds (200));
   SDL.Log.Put_Debug ("After Wait_Delay, ticks: " & Ticks);
end Timers;

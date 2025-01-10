--------------------------------------------------------------------------------------------------------------------
--  This source code is subject to the Zlib license, see the LICENCE file in the root of this directory.
--------------------------------------------------------------------------------------------------------------------
with Ada.Strings.UTF_Encoding.Wide_Wide_Strings;
with Ada.Strings.Unbounded;
with Ada.Real_Time; use Ada.Real_Time;
with SDL;
with SDL.Error;
with SDL.Events.Events;
with SDL.Events.Keyboards;
with SDL.Events.Windows;
with SDL.Log;
with SDL.Video.Windows;
with SDL.Video.Windows.Makers;
with SDL.Video.Vulkan;
with System;

procedure Vulkan is
   W : SDL.Video.Windows.Window;
   Width, Height : SDL.Natural_Dimension;

   package Vulkan is new SDL.Video.Vulkan (Instance_Address_Type => System.Address,
                                           Instance_Null         => System.Null_Address,
                                           Surface_Type          => System.Address);
begin
   SDL.Log.Set (Category => SDL.Log.Application, Priority => SDL.Log.Debug);

   if SDL.Initialise = True then
      SDL.Error.Clear;

      SDL.Video.Windows.Makers.Create (Win      => W,
                                       Title    => Ada.Strings.UTF_Encoding.Wide_Wide_Strings.Encode
                                                     ("Test SDLAda 2.0 - हिन्दी समाचार"),
                                       Position => SDL.Natural_Coordinates'(X => 100, Y => 100),
                                       Size     => SDL.Positive_Sizes'(800, 640),
                                       Flags    => SDL.Video.Windows.Vulkan);

      Vulkan.Load_Library;

      declare
         Names : constant Vulkan.Extension_Name_Arrays := Vulkan.Get_Instance_Extensions (W);

         use type Vulkan.Extension_Name_Arrays;
      begin
         if Names = Vulkan.Null_Extension_Name_Array then
            raise Vulkan.SDL_Vulkan_Error with SDL.Error.Get;
         end if;

         SDL.Log.Put_Debug ("Vulkan Instance Extensions: " & Names'Last'Image);

         for N of Names loop
            SDL.Log.Put_Debug ("  " & Ada.Strings.Unbounded.To_String (N));
         end loop;
      end;

      Vulkan.Get_Drawable_Size (W, Width, Height);

      SDL.Log.Put_Debug ("Drawable Size = (" & Width'Image & ", " & Height'Image & ")");

      Main_Loop : declare
         Event    : SDL.Events.Events.Events;
         Finished : Boolean := False;

         Loop_Start_Time_Goal : Ada.Real_Time.Time;

         Frame_Duration : constant Ada.Real_Time.Time_Span :=
           Ada.Real_Time.Microseconds (6_944);
         --  144 Hz refresh rate

         use type SDL.Events.Keyboards.Key_Codes;
         use type SDL.Events.Windows.Window_Event_ID;
      begin
         --  Set next frame delay target using monotonic clock time
         Loop_Start_Time_Goal := Ada.Real_Time.Clock;

         loop
            --  Limit event loop to 144 Hz using realtime "delay until"
            Loop_Start_Time_Goal := Loop_Start_Time_Goal + Frame_Duration;
            delay until Loop_Start_Time_Goal;

            while SDL.Events.Events.Poll (Event) loop
               case Event.Common.Event_Type is
                  when SDL.Events.Quit =>
                     Finished := True;

                  when SDL.Events.Keyboards.Key_Up =>
                     SDL.Log.Put_Debug ("Key up event    : " &
                                          SDL.Events.Keyboards.Key_Codes'Image (Event.Keyboard.Key_Sym.Key_Code) &
                                          "    Scan code: " &
                                          SDL.Events.Keyboards.Scan_Codes'Image (Event.Keyboard.Key_Sym.Scan_Code));

                     if Event.Keyboard.Key_Sym.Key_Code = SDL.Events.Keyboards.Code_Escape then
                        Finished := True;
                     end if;

                  when others =>
                     null;
               end case;
            end loop;

            exit when Finished;
         end loop;
      end Main_Loop;

      Vulkan.Unload_Library;

      W.Finalize;
      SDL.Finalise;
   end if;
end Vulkan;

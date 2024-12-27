*******************************************************************
         S O U N D    C A R D    S U P P O R T    7/98
*******************************************************************
The shareware utility PLANY is incorporated to provide support
for sound card sounds, along with a variety of WAV sound files.
To enable this support, type

CW s

You may need to adjust your speaker volume to get the proper
sound level. The sounds slow gameplay and may be unacceptable
on some systmes.

Although the PLANY utility supports a variety of sound cards,
there is no guarantee it work on any given system.

****************************************************************
                      Changes in Version 2.56  9/97
****************************************************************
1. Some communications software packages append extra carriage
   returns / line feeds to the PBM e-mail file. The game cannot
   read the file in these cases. A small utility PBMFIX will
   remove these extra characters. If you have a problem reading
   the PBM e-mail file, run PBMFIX one time. If that doesn't fix
   the problem, there is something else wrong with the file. The
   original PBM game file is saved as SAVEGAME.OLD if you need
   to recover it.

****************************************************************
                      Changes in Version 2.5   6/96
****************************************************************
1. A Play-by-Mail feature has been added. This works in the
   following way:

a) Player 1 chooses the option 'Begin a NEW PBM Game', then
   selects a scenario to play.

b) Player 1 chooses the 'Fight' option and plays 10 turns of the
   game against the computer. At the end of 10 turns, the game is
   interrupted, and a PBM file is created. This file is named
   SAVEGAME.PBM, and is similar to the normal *.CIV scenario
   files, but it has been specially encrypted and cannot be edited
   using the game editor.

c) Player 1 sends the PBM file to Player 2 (this can be either
   via e-mail or on a disk through the postal service.

d) Player 2 transfers the file to his system, then starts the
   game and selects the 'Continue PBM Game' option.

   The PBM file will be loaded and unencrypted. This process is
   slightly slower than loading a normal scenario, and causes a
   small temporary file to be built on the hard drive during
   unencryption (which requires in several disk accesses).

   As the file is unencrypted, a checksum is also calculated to
   ensure file integrity. If the checksum does not match, that
   fact is reported but the game can continue. A non-match on the
   checksum means the file may have been damaged, changed, or
   corrupted in some way since it was created.

   After the file is unencrypted, the side is automatically
   switched. For instance, if Player 1 was playing the Rebel
   side, the game will switch to the Union side for Player 2.

e) Player 2 chooses the 'Fight' option and plays 10 turns of the
   game against the computer. At the end of 10 turns, the game is
   interrupted, and a SAVEGAME.PBM file is created to send to
   Player 1.
f) Play continues until the game is over. Final
   statistics are displayed for both sides. If desired, the final
   SAVEGAME.PBM file can be sent to the other player, who may
   then select the 'Fight' option to view the final results.

   Note that once you have begun the "Fight" phase with the PBM
   game, you cannot manually exit back to the main menu until you
   have finished the turns for the side you are playing.

   Also note that once the PBM game has begun with a given set of
   parameters, they remain constant during the remainder of the
   game and cannot be changed, since they are embedded in the PBM
   game file itself.

2. Units that eliminate an enemy now have the option to advance
   immediately into the enemy hex.

****************************************************************************
   Changes to CIVILWAR BATTLE SET version 2.4         1/95
****************************************************************************
1. A new 'CAMPAIGN' option has been added, which allows
individual battles to be conducted in a more strategic context.
When this option is selected, a map of the U.S. will appear, with
19 regions shown. The user is given the option to CONTINUE an
existing campaign (if one is in progress) or begin a NEW
campaign. When beginning a new campaign, you will note that the
Washington region is shown in blue (indicating Union control),
while the Richmond region is shown in red. You will also note the
message showing the scores required for victory in a region,
which is 50% (for an unoccupied region), 53% (for a region
controlled by the enemy), and 58% (for enemy capital region).
These values are the battle score percentages required to win
control of the region. The percentages change depending on
difficulty; the figures above are for the base difficulty level.

               Victory % Needed To Capture a Region

        Region                  Percentage Needed
   ===========================  ===================
   Controlled by enemy              Base % *
   Capital region                  Base % + 5%
   Uncontrolled by either side        50%

* Base % depends on difficulty level.

   As the campaign progresses, the winner of the previous battle
   for a region will select a new region for the battle. (This
   selection is made randomly in starting a NEW campaign). Then
   an appropriate battle scenario will be loaded, and the battle
   fought for control of the campaign region.

   The first side to control 10 regions of the 19 will win the
   entire campaign. Note that if one side eliminates all the
   enemy held regions, this does NOT result in victory, since the
   enemy is presumed still to have forces in all the regions that
   are yet not controlled by the other side.

   The selection of the specific battle for a given region is
   controlled by the file CAMPAIGN.INI. This file contains a
   record for each of the 19 regions, structured as shown in the
   example for region #1, Gettysburg:

1,2,3,0,0,0,0,3,56,Gettysburg,3,getty1.civ,getty2.civ,getty3.civ
| |---------| | |     |       | |-------------------------------|
|     |       | |     |       | Individual Battle scenario names
|     |       | |     |       |
|     |       | |     |    Number of battle scenarios in region
|     |       | |     |
|     |       | |  Region name
|     |       | |
|     |      (y,x) Map Coordinates
|     |
|     Connections to other regions
|
Region Number (1-19)

    In addition, there are 2 files used to track the progress of
    the campaign: REGIONS.INI (which contains who initially
    controls each region) and REGIONS.SAV (who controls each
    region for a saved campaign in progress). Note that there is
    only one saved campaign file, and it is overwritten if
    another in-progress campaign is saved.

    In addition to the "real" battle scenarios, there can be up
    to 10 other generated "fantasy" scenarios that may be used.
    These are named CAMPxx.CIV, where xx is a number from 00 to
    09. If there are no battle scenarios for a given region, one
    of these generated scenarios is randomly selected. Even if
    there are battle scenarios for a region, there is a 10%
    chance of a one of these generated "fantasy" scenarios being
    randomly selected. Each time a "fantasy" scenario is set up,
    the starting position will be slightly randomized to provide
    an extra challenge.
    
    For each region a side controls, one of their units receives
    a BONUS in strength, and has a 50% chance of receiving a
    bonus in leadership and morale. For instance, if you control
    4 regions, 4 of your units will receive a bonus.

    Note that high score tracking for individual battles is not
    available during the campaign since the emphasis is on the
    overall conduct of the war.

*****************************************************************
*  NOTE: A campaign battle CANNOT be saved while in progress.   *
*  However, the campaign can be stopped after any battle in the *
*  campaign is completed, and resumed where you left off.       *
*****************************************************************

2. The Hall of Fame history interface has been improved to allow
   you to select previous names from a menu. In addition, a
   utility is provided in the PARAMETERS submenu to clear history
   files.

3. Several minor improvements have been made:
    (a) Units can no longer seize an enemy held objective as a
        result of their retreat move. This is done on the
        presumption that there are a few pickets left at the
        objective once it is seized, even if no unit remains on
        that hex.
    (b) Charging units that are Rested will stop charging.
    (c) Switching to an alternate objective is done more
        smoothly.

4. Combat INTENSITY can be reduced using an option in the
   PARAMETERS submenu. The setting affects relative level of
   casualties taken by both sides involved in combat, as well as
   level of casualties from artillery fire. (Default setting is
   NORMAL).

5. The option to initially WAIT units has been added to the game
   editor. This is slightly different from DELAY in that such
   units can be activated at any time during the actual game,
   while DELAYed units will not activate until the delay period
   has elapsed. The graphics in the editor have been changed
   slightly to distinguish WAITED units from DELAYED units, which
   are now are shown with a black outline.

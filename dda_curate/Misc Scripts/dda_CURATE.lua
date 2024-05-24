--[[ 
@version 1.0.2
@description dda_CURATE – Instant sound curation for Reaper.
@about
    dda_CURATE is a set of Reaper scripts to help you rate, organize, and categorize your sounds quickly and easily.
  
    -  Rate your sounds using a color-coding system to quickly determine which ones you prefer and organize them together
    -  Easily move sounds to child tracks to keep similar sounds together
    -  Add unique description metadata to individual sounds as well as project metadata to all sounds in your collection
    -  Reorder your sounds based on different variables including item length or rating to keep your project neat and tidy
    -  Printout all project sound information in one easy-to-read, easy-to-copy-paste window
    -  And more!

@author David Dumais

@links:
  Store Page: https://daviddumaisaudio.gumroad.com/l/dda_CURATE

@provides
  Categorization Scripts/Add text to selected item notes.lua
  Categorization Scripts/Clear notes from all selected items.lua
  Categorization Scripts/Copy paste item notes.lua
  Categorization Scripts/Find and select all items with user defined text notes from selected items selection.lua
  Categorization Scripts/Find and select all items with user defined text notes in project.lua
  Categorization Scripts/Find and select all items with user defined text notes on selected tracks.lua
  Categorization Scripts/Item group tracks become child of a new parent track.lua
  Categorization Scripts/Move item to child track within parent folder.lua
  Categorization Scripts/Move item(s) to a new child track of selected track.lua
  Categorization Scripts/Reorder Selected Items on a track based on item length - Longest to shortest (1 second apart).lua
  Categorization Scripts/Reorder Selected Items on a track based on item length - shortest to longest (1 second apart).lua
  Categorization Scripts/Reposition items (1 second apart) even across multiple tracks.lua
  Categorization Scripts/Reposition items even across multiple tracks - user defined length.lua
  Metadata Scripts/Add description metadata to selected item notes.lua
  Metadata Scripts/Add project artist metadata region to selected items.lua
  Metadata Scripts/Add project comments or notes metadata region to selected items.lua
  Metadata Scripts/Add project copyright metadata region to selected items.lua
  Metadata Scripts/Add project metadata regions (all-in-one).lua
  Metadata Scripts/Add project name metadata region to selected items.lua
  Metadata Scripts/Add project publisher metadata region to selected items.lua
  Metadata Scripts/Create individual regions for selected items and rename region using item notes.lua
  Misc Scripts/Select next item, move cursor to item, preserve play state.lua
  Misc Scripts/Select previous item, move cursor to item, preserve play state.lua
  Misc Scripts/Selected items information printout.lua
  Rating Scripts/Change rating colors.lua
  Rating Scripts/Order selected grouped items by rating (high to low).lua
  Rating Scripts/Order selected grouped items by rating (low to high).lua
  Rating Scripts/Order selected items on track based on rating (high to low).lua
  Rating Scripts/Order selected items on track based on rating (low to high).lua
  Rating Scripts/Select all #1 color-rated items in project.lua
  Rating Scripts/Select all #1 color-rated items on selected tracks only.lua
  Rating Scripts/Select all #1,2 color-rated items in project.lua
  Rating Scripts/Select all #1,2 color-rated items on selected tracks only.lua
  Rating Scripts/Select all #1,2,3 color-rated items in project.lua
  Rating Scripts/Select all #1,2,3 color-rated items on selected tracks only.lua
  Rating Scripts/Select all #1,2,3,4 color-rated items in project.lua
  Rating Scripts/Select all #1,2,3,4 color-rated items on selected tracks only.lua
  Rating Scripts/Select all #1,2,3,4,5 color-rated items in project.lua
  Rating Scripts/Select all #1,2,3,4,5 color-rated items on selected tracks only.lua
  Rating Scripts/Select all #2 color-rated items in project.lua
  Rating Scripts/Select all #2 color-rated items on selected tracks only.lua
  Rating Scripts/Select all #2,3,4,5 color-rated items in project.lua
  Rating Scripts/Select all #2,3,4,5 color-rated items on selected tracks only.lua
  Rating Scripts/Select all #3 color-rated items in project.lua
  Rating Scripts/Select all #3 color-rated items on selected tracks only.lua
  Rating Scripts/Select all #3,4,5 color-rated items in project.lua
  Rating Scripts/Select all #3,4,5 color-rated items on selected tracks only.lua
  Rating Scripts/Select all #4 color-rated items in project.lua
  Rating Scripts/Select all #4 color-rated items on selected tracks only.lua
  Rating Scripts/Select all #4,5 color-rated items in project.lua
  Rating Scripts/Select all #4,5 color-rated items on selected tracks only.lua
  Rating Scripts/Select all #5 color-rated items in project.lua
  Rating Scripts/Select all #5 color-rated items on selected tracks only.lua
  Rating Scripts/Set selected items to color rating #1.lua
  Rating Scripts/Set selected items to color rating #2.lua
  Rating Scripts/Set selected items to color rating #3.lua
  Rating Scripts/Set selected items to color rating #4.lua
  Rating Scripts/Set selected items to color rating #5.lua
  Rating Scripts/Show and change rating colors.lua

@changelog
  v1.0.2
    + added all scripts to 1 single package
  v1.0.1
    + minor changes
  v1.0.0
    - initial release

  --]]

reaper.ShowMessageBox("dda_CURATE is a set of Reaper scripts to help you rate, organize, and categorize your sounds quickly and easily. \n\ndda_ITEM, dda_RATING, dda_METADATA, dda_CATEGORIZATION" , "dda_CURATE", 0)
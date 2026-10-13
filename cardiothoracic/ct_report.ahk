/*
==============================================================================
CARDIOTHORACIC PATHOLOGY SHORTCUTS - USER GUIDE
==============================================================================
Welcome! This script automates common cardiothoracic pathology reporting, 
including multi-line grading templates, dynamic lung specimens, and smart 
lymph node counting.

HOW TO TRIGGER:
Type any of the shortcuts below and press SPACE, TAB, or ENTER to expand them.
Shortcuts are case-insensitive as you type.

------------------------------------------------------------------------------
FEATURE 1: MULTI-LINE REPORTS & GRADING
Type the abbreviation to instantly generate a full, formatted multi-line report.
  
  emb0 -> Heart, allograft, endomyocardial biopsy
          - ISHLT grade 0R
          - No evidence of acute cellular rejection
          - No histologic features suggestive of antibody mediated rejection

------------------------------------------------------------------------------
FEATURE 2: LUNG SPECIMEN DESCRIPTIONS
String together a location and a procedure to instantly generate standardized 
lung specimen descriptions.

  Formula: [Location] + [Procedure]

  [Location]   r = right | l = left
               rul = right upper lobe | rml = right middle lobe | rll = right lower lobe
               lul = left upper lobe | lling = left lingula | lll = left lower lobe

  [Procedure]  bx = biopsy | tbbx = transbronchial biopsy | etbx = endobronchial biopsy
               ctbx = CT-guided core biopsy | w = wedge resection | ex = explant

  Examples:
  rbx      -> Lung, right, biopsy
  rultbbx  -> Lung, right upper lobe, transbronchial biopsy
  rulex    -> Lung, right upper lobe, explant

------------------------------------------------------------------------------
FEATURE 3: LYMPH NODES (Single Node - Excisional Biopsy)
For single nodes. Simply add 'n' for negative (0/1) or 'p' for positive (1/1).

  Formula: ln + [Station] + [n/p]
  [Station] 1 to 14 (Includes R, L, a, p, b modifiers)
  
  Examples:
  ln4rn -> Lymph node, level 4R, excisional biopsy
           - One lymph node with no evidence of malignancy (0/1)
  ln7p  -> Lymph node, level 7, excisional biopsy
           - One lymph node positive for malignancy (1/1)

------------------------------------------------------------------------------
FEATURE 4: LYMPH NODES (Dissection Packet - All Negative)
For bundles/packets of fat yielding multiple negative nodes (Up to 30 nodes).
Use 'd' (for dissection) followed by the total number of nodes found.

  Formula: ln + [Station] + d + [Total Nodes Found]
  
  Examples:
  ln10d12 -> Lymph node, level 10, dissection
             - 12 lymph nodes with no evidence of malignancy (0/12)
  ln8ad1  -> Lymph node, level 8a, dissection
             - 1 lymph node with no evidence of malignancy (0/1)

------------------------------------------------------------------------------
FEATURE 5: LYMPH NODES (Dissection Packet - With Positives)
For bundles/packets yielding multiple nodes, where SOME are positive (Up to 15 total nodes).
Add 'p' and the number of positive nodes to the end of the Feature 4 formula.

  Formula: ln + [Station] + d + [Total Nodes Found] + p + [Positive Nodes]
  
  Examples:
  ln2rd14p3 -> Lymph node, level 2R, dissection
               - 3 lymph nodes positive for malignancy (3/14)
  ln4ld5p1  -> Lymph node, level 4L, dissection
               - 1 lymph node positive for malignancy (1/5)
==============================================================================
*/

#Requires AutoHotkey v2.0

; Limits trigger keys to ONLY Enter (`n), Tab (`t), and Space (`s)
#Hotstring EndChars `n`t`s

; ==============================================================================
; CONFIGURATION (Add or modify your vocabulary here)
; ==============================================================================

; --- 1. Multi-line Reports (Keep complex/unique templates here) ---
; Note: `n creates a new line, and `t creates a tab indent.
ct_reports := Map(
    "emb0", "Heart, allograft, endomyocardial biopsy`n`t- ISHLT grade 0R`n`t- No evidence of acute cellular rejection`n`t- No histologic features suggestive of antibody mediated rejection"
)

; --- 2. Lung Specimen Definitions (For Engine 2) ---
lung_locations := Map(
    "r", "right",
    "l", "left",
    "rul", "right upper lobe",
    "rml", "right middle lobe",
    "rll", "right lower lobe",
    "lul", "left upper lobe",
    "lling", "left lingula",
    "lll", "left lower lobe"
)

lung_procedures := Map(
    "bx", "biopsy",
    "tbbx", "transbronchial biopsy",
    "etbx", "endobronchial biopsy",
    "ctbx", "CT-guided core biopsy",
    "w", "wedge resection",
    "l", "lobectomy",
    "ex", "explant"
)

; --- 3. Lymph Node Suffixes (For Engine 3) ---
; Define exactly how you want them to appear in the report
ln_suffixes := ["", "R", "L", "a", "p", "b"]

; ==============================================================================
; ENGINE (Do not modify below this line unless changing calculation logic)
; ==============================================================================

; --- ENGINE 1: Multi-line Reports ---
for prefix, reportText in ct_reports
{
    ; Waits for Space/Tab/Enter (XO omits the trigger key)
    Hotstring(":XO:" prefix, InsertReport.Bind(reportText))
}

; --- ENGINE 2: Lung Specimen Naming ---
; Automatically generates all combinations (e.g., rbx, rultbbx)
for locCode, locName in lung_locations 
{
    for procCode, procName in lung_procedures 
    {
        shortcut := locCode procCode
        reportText := "Lung, " locName ", " procName
        
        ; Waits for Space/Tab/Enter (XO omits the trigger key)
        Hotstring(":XO:" shortcut, InsertReport.Bind(reportText))
    }
}

; --- ENGINE 3: Smart Lymph Node Generator ---
Loop ln_suffixes.Length 
{
    sufVal := ln_suffixes[A_Index]
    
    Loop 14 
    {
        stationNum := A_Index
        
        ; Explicitly concatenates the number and the letter (e.g., 8 + b = 8b)
        stationName := stationNum . sufVal
        
        ; FEATURE 3: Excisional Biopsy (Single Node Negative/Positive)
        reportNeg := "Lymph node, level " stationName ", excisional biopsy`n`t- One lymph node with no evidence of malignancy (0/1)"
        Hotstring(":XO:ln" stationName "n", InsertReport.Bind(reportNeg))
        
        reportPos := "Lymph node, level " stationName ", excisional biopsy`n`t- One lymph node positive for malignancy (1/1)"
        Hotstring(":XO:ln" stationName "p", InsertReport.Bind(reportPos))

        ; FEATURE 4: Dissection Packet - All Negative (Dynamic Count up to 30 nodes)
        Loop 30 
        {
            totalCount := A_Index
            totalPlural := (totalCount == 1) ? "lymph node" : "lymph nodes"
            
            reportDissectionNeg := "Lymph node, level " stationName ", dissection`n`t- " totalCount " " totalPlural " with no evidence of malignancy (0/" totalCount ")"
            Hotstring(":XO:ln" stationName "d" totalCount, InsertReport.Bind(reportDissectionNeg))
        }

        ; FEATURE 5: Dissection Packet - With Positives (Dynamic Count up to 15 nodes)
        Loop 15 
        {
            totalCount := A_Index
            
            Loop totalCount 
            {
                posCount := A_Index
                posPlural := (posCount == 1) ? "lymph node" : "lymph nodes"
                
                reportDissectionPos := "Lymph node, level " stationName ", dissection`n`t- " posCount " " posPlural " positive for malignancy (" posCount "/" totalCount ")"
                Hotstring(":XO:ln" stationName "d" totalCount "p" posCount, InsertReport.Bind(reportDissectionPos))
            }
        }
    }
}

; ==============================================================================
; SHARED FUNCTIONS 
; (⚠️ Move this to your master file once you start combining multiple scripts!)
; ==============================================================================

InsertReport(text, ThisHotkey)
{
    ; SendText is safer than Send for fast typing and ignores special modifier characters
    SendText(text)
}
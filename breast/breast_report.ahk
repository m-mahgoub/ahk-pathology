/*
==============================================================================
BREAST PATHOLOGY SHORTCUTS - USER GUIDE
==============================================================================
Welcome! This script automates common breast pathology reporting, including 
automatic ESBR grade calculations and complex specimen descriptions.

HOW TO TRIGGER:
Type any of the shortcuts below and press SPACE, TAB, or ENTER to expand them.

------------------------------------------------------------------------------
FEATURE 1: BASIC DIAGNOSES
Just type the abbreviation to get the full disease name.
  idc  ->  Invasive ductal carcinoma
  ilc  ->  Invasive lobular carcinoma
  imc  ->  Invasive mammary carcinoma

------------------------------------------------------------------------------
FEATURE 2: SMART DIAGNOSIS + ESBR GRADING
Add 3 numbers (1, 2, or 3) to the end of a diagnosis. The numbers represent 
your Tubule, Nucleus, and Mitoses scores. The script will automatically calculate 
the total score, determine the grade, and format the text.

  Format:  [Diagnosis] + [Tubules] + [Nucleus] + [Mitoses]
  Example: idc121
  Output:  Invasive ductal carcinoma, Histologic grade = 1/3 (score: tubules 1 + nucleus 2 + mitoses 1 = 4/9) by ESBR criteria

------------------------------------------------------------------------------
FEATURE 3: STANDALONE GRADING
If you only want the grading text (without the diagnosis attached), use "ig".

  Format:  ig + [Tubules] + [Nucleus] + [Mitoses]
  Example: ig222
  Output:  Histologic grade = 2/3 (score: tubules 2 + nucleus 2 + mitoses 2 = 6/9) by ESBR criteria

------------------------------------------------------------------------------
FEATURE 4: SPECIMEN DESCRIPTIONS (Biopsy/Grossing)
You can string together letters and numbers to instantly generate complex 
specimen descriptions. Always start with "b" (for breast).

  The Formula: b + [Side] + [Clock] + [Distance] + [Modality] + [Procedure]

  [Side]       r = right | l = left
  [Clock]      1o to 12o (e.g., 2o = 2:00)                  *Optional
  [Distance]   1n to 15n (e.g., 3n = 3 cm from nipple)      *Optional
  [Modality]   us = ultrasound | mr = MRI | st = stereotactic *Optional
  [Procedure]  b = biopsy | cb = core biopsy | ex = excision | ms = mastectomy | pms = partial mastectomy

  Examples:
  brcb         -> Breast, right, core biopsy
  bl2ouscb     -> Breast, left, 2:00, ultrasound-guided core biopsy
  br10o5nstpms -> Breast, right, 10:00, 5 cm from nipple, stereotactic partial mastectomy
==============================================================================
*/

#Requires AutoHotkey v2.0

; Limits trigger keys to ONLY Enter (`n), Tab (`t), and Space (`s)
#Hotstring EndChars `n`t`s

; ==============================================================================
; CONFIGURATION (Add or modify your vocabulary here)
; ==============================================================================

; --- 1. Diagnosis Definitions ---
diagnoses := Map(
    "idc", "Invasive ductal carcinoma",
    "ilc", "Invasive lobular carcinoma",
    "imc", "Invasive mammary carcinoma"
)

; --- 2. Specimen Definitions ---
sides := Map(
    "r", "right",
    "l", "left"
)

modalities := Map(
    "", "", 
    "us", "ultrasound-guided ", 
    "mr", "MRI-guided ", 
    "st", "stereotactic "
)

procedures := Map(
    "b", "biopsy",
    "cb", "core biopsy",
    "ex", "excision",
    "ms", "mastectomy",
    "pms", "partial mastectomy"   ; Added partial mastectomy
)

; ==============================================================================
; ENGINE (Do not modify below this line unless changing calculation logic)
; ==============================================================================

; --- ENGINE 1A: Diagnosis & Grading (e.g., idc121) ---
for prefix, fullName in diagnoses
{
    ; Base diagnosis (No grading) - Bullets and tabs removed
    baseText := fullName
    Hotstring(":XO:" prefix, InsertReport.Bind(baseText))

    ; Graded diagnosis 
    Loop 3 {
        t := A_Index
        Loop 3 {
            n := A_Index
            Loop 3 {
                m := A_Index
                
                total := t + n + m
                grade := (total <= 5) ? 1 : (total <= 7) ? 2 : 3
                
                ; Updated to your specific ESBR text format
                reportText := fullName ", Histologic grade = " grade "/3 (score: tubules " t " + nucleus " n " + mitoses " m " = " total "/9) by ESBR criteria"
                
                Hotstring(":XO:" prefix t n m, InsertReport.Bind(reportText))
            }
        }
    }
}

; --- ENGINE 1B: Standalone Grading Only (e.g., ig121) ---
; Generates ONLY the grading text without attaching a diagnosis to the front
Loop 3 {
    t := A_Index
    Loop 3 {
        n := A_Index
        Loop 3 {
            m := A_Index
            
            total := t + n + m
            grade := (total <= 5) ? 1 : (total <= 7) ? 2 : 3
            
            reportText := "Histologic grade = " grade "/3 (score: tubules " t " + nucleus " n " + mitoses " m " = " total "/9) by ESBR criteria"
            
            Hotstring(":XO:ig" t n m, InsertReport.Bind(reportText))
        }
    }
}

; --- ENGINE 2: Specimen Naming ---
for sideCode, sideName in sides 
{
    Loop 13 {
        clockVal := A_Index - 1
        clockCode := (clockVal == 0) ? "" : clockVal "o"
        
        ; Replaced "o'clock" with the ":00" format 
        clockText := (clockVal == 0) ? "" : clockVal ":00, "
        
        Loop 16 {
            distVal := A_Index - 1
            distCode := (distVal == 0) ? "" : distVal "n"
            distText := (distVal == 0) ? "" : distVal " cm from nipple, "
            
            for modCode, modName in modalities {
                for procCode, procName in procedures {
                    
                    shortcut := "b" sideCode clockCode distCode modCode procCode
                    reportText := "Breast, " sideName ", " clockText distText modName procName
                    
                    ; Waits for Space/Tab/Enter (XO omits the trigger key)
                    Hotstring(":XO:" shortcut, InsertReport.Bind(reportText))
                }
            }
        }
    }
}

; ==============================================================================
; SHARED FUNCTIONS 
; ==============================================================================

InsertReport(text, ThisHotkey)
{
    ; SendText is safer than Send for fast typing and ignores special modifier characters
    SendText(text)
}
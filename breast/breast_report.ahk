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
    "ms", "mastectomy" 
)

; ==============================================================================
; ENGINE (Do not modify below this line unless changing calculation logic)
; ==============================================================================

; --- ENGINE 1: Diagnosis & Grading ---
for prefix, fullName in diagnoses
{
    ; Base diagnosis (No grading) - Waits for Space/Tab/Enter (XO omits the trigger key)
    baseText := "• " fullName
    Hotstring(":XO:" prefix, InsertReport.Bind(baseText))

    ; Graded diagnosis - Now also waits for Space/Tab/Enter (Changed :X*: to :XO:)
    Loop 3 {
        t := A_Index
        Loop 3 {
            n := A_Index
            Loop 3 {
                m := A_Index
                
                total := t + n + m
                grade := (total <= 5) ? 1 : (total <= 7) ? 2 : 3
                
                reportText := "• " fullName ", grade " grade "/3, (T=" t "/3, N=" n "/3, M=" m "/3)"
                
                ; Removed the *, replaced with O so it requires a trigger key and omits it
                Hotstring(":XO:" prefix t n m, InsertReport.Bind(reportText))
            }
        }
    }
}

; --- ENGINE 2: Specimen Naming ---
for sideCode, sideName in sides 
{
    Loop 13 {
        clockVal := A_Index - 1
        clockCode := (clockVal == 0) ? "" : clockVal "o"
        clockText := (clockVal == 0) ? "" : clockVal " o'clock, "
        
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
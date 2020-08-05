//
//  ExcelWrite.swift
//  DMCTuner
//
//  Created by Rick Street on 3/9/17.
//  Copyright © 2017 Rick Street. All rights reserved.
//

import Cocoa
import xlsxwriter
import DmcKit

class ExcelWrite {
    
    // dmcController declared globally
    let controller = SingletonDMController.sharedInstance
    
    
    var cvs = [Section]()
    var mvs = [Section]()
    var ffs = [Section]()
    var inds = [Section]()
    var gmults = [GMult]()
    var calcSection = Section()
    var calcParams = [ConfigParam]()
    var excelInstalled = false
    
    
    
    
    var fileName = ""
    
    let red: Int32 = 0xFF0000
    let black: Int32 = 0x000000
    let navy: Int32 = 0x000080
    let green: Int32 = 0x008000
    let silver: Int32 = 0xC0C0C0
    let yellow: Int32 = 0xFFFF00
    let center: UInt8 = 2
    
    func write() {
        cvs = controller.config.cvs
        mvs = controller.config.mvs
        ffs = controller.config.ffs
        inds = controller.config.inds
        gmults = controller.config.gMults
        calcSection = controller.config.calcSection
        calcParams = controller.config.calcParams
        
        //let saveURL = SaveURL()
        /*
         let file = File()
         file.title = "Excel  File"
         file.message = "Enter or select Excel file."
         // saveURL.nameFieldStringValue = dmcController.controllerName + "_info.xlsx"
         file.allowedFileTypes = ["xlsx"]
         */
        
        let url = controller.config.configURL
        let excelURL = url.deletingPathExtension().appendingPathExtension("xlsx")
        
        fileName = excelURL.path
        run()
        /*
         if let url = file.save(url: excelURL) {
         excelURL = url
         fileName = url.path
         run()
         
         }
         */
        
        
        // print("path: \(configPath)")
        // print("name: \(controllerName)")
        // print("save: \(saveURL.nameFieldStringValue)")
        
        // if let url = saveURL.open() {
        
        // let myUrl = url.deletingLastPathComponent()
        // UserDefaults.standard.set(url.path, forKey: "ControllerPath")
        
        // fileName = url.path
        // print(fileName)
        // run()
        
        // If Excel installed, open in Excel
        let fm = FileManager.default
        let urlExcelProgram = URL(fileURLWithPath: "/Applications/Microsoft Excel.app")
        if fm.fileExists(atPath: urlExcelProgram.path) {
            self.excelInstalled = true
            // print("found \(urlExcel.path)")
        }
        
        if self.excelInstalled {
            NSWorkspace.shared.open(excelURL)
        }
        
        
        
        // }
    }
    
    func run() {
        
        // Create a new workbook.
        let workbook = workbook_new((fileName as NSString).utf8String)
        
        
        // Setup Formats
        
        // Ind Title
        let formatTitle = workbook_add_format(workbook)
        format_set_bold(formatTitle)
        format_set_italic(formatTitle)
        format_set_font_size(formatTitle, 12)
        format_set_font_color(formatTitle, lxw_color_t(navy))
        
        // Header Fomat
        let formatHeader = workbook_add_format(workbook)
        format_set_bottom(formatHeader, 1)
        format_set_top(formatHeader, 1)
        format_set_right(formatHeader, 1)
        format_set_left(formatHeader, 1)
        format_set_bold(formatHeader)
        format_set_italic(formatHeader)
        format_set_font_size(formatHeader, 10)
        format_set_text_wrap(formatHeader)
        
        // Header Left Border
        let formatHeaderLeft = workbook_add_format(workbook)
        format_set_bottom(formatHeaderLeft, 1)
        format_set_top(formatHeaderLeft, 1)
        // format_set_right(formatHeaderLeft, 1)
        format_set_left(formatHeaderLeft, 1)
        format_set_bold(formatHeaderLeft)
        format_set_italic(formatHeaderLeft)
        format_set_font_size(formatHeaderLeft, 10)
        format_set_text_wrap(formatHeaderLeft)
        
        // Header Right Border
        let formatHeaderRight = workbook_add_format(workbook)
        // format_set_bottom(formatHeaderRight, 1)
        // format_set_top(formatHeaderRight, 1)
        format_set_right(formatHeaderRight, 1)
        // format_set_left(formatHeaderRight, 1)
        format_set_bold(formatHeaderRight)
        format_set_italic(formatHeaderRight)
        format_set_font_size(formatHeaderRight, 10)
        format_set_text_wrap(formatHeaderRight)
        
        // Header Left Top Border
        let formatHeaderLeftTop = workbook_add_format(workbook)
        // format_set_bottom(formatHeaderLeftTop, 1)
        format_set_top(formatHeaderLeftTop, 1)
        // format_set_right(formatHeaderLeftTop, 1)
        format_set_left(formatHeaderLeftTop, 1)
        format_set_bold(formatHeaderLeftTop)
        format_set_italic(formatHeaderLeftTop)
        format_set_font_size(formatHeaderLeftTop, 10)
        // format_set_text_wrap(formatHeaderLeftTop)
        
        // Header Right Top Border
        let formatHeaderRightTop = workbook_add_format(workbook)
        // format_set_bottom(formatHeaderRightTop, 1)
        format_set_top(formatHeaderRightTop, 1)
        format_set_right(formatHeaderRightTop, 1)
        // format_set_left(formatHeaderRightTop, 1)
        format_set_bold(formatHeaderRightTop)
        format_set_italic(formatHeaderRightTop)
        format_set_font_size(formatHeaderRightTop, 10)
        format_set_text_wrap(formatHeaderRightTop)
        
        // Header Upper (right, left, top)
        let formatHeaderUpper = workbook_add_format(workbook)
        // format_set_bottom(formatHeaderUpper, 1)
        format_set_top(formatHeaderUpper, 1)
        format_set_right(formatHeaderUpper, 1)
        format_set_left(formatHeaderUpper, 1)
        format_set_bold(formatHeaderUpper)
        format_set_italic(formatHeaderUpper)
        format_set_font_size(formatHeaderUpper, 10)
        format_set_text_wrap(formatHeaderUpper)
        
        
        // Header Lower (right, left, bottom)
        let formatHeaderLower = workbook_add_format(workbook)
        format_set_bottom(formatHeaderLower, 1)
        // format_set_top(formatHeaderLower, 1)
        format_set_right(formatHeaderLower, 1)
        format_set_left(formatHeaderLower, 1)
        format_set_bold(formatHeaderLower)
        format_set_italic(formatHeaderLower)
        format_set_font_size(formatHeaderLower, 10)
        format_set_text_wrap(formatHeaderLower)
        
        
        
        // Top Row
        let formatTopRow = workbook_add_format(workbook)
        format_set_num_format(formatTopRow, "##0")
        format_set_right(formatTopRow, 1)
        format_set_left(formatTopRow, 1)
        format_set_top(formatTopRow, 1)
        format_set_bottom(formatTopRow, 1)
        format_set_bottom_color(formatTopRow, lxw_color_t(silver))
        format_set_font_size(formatTopRow, 10)
        
        // Middle Row
        let formatMiddleRow = workbook_add_format(workbook)
        format_set_num_format(formatMiddleRow, "##0")
        format_set_text_wrap(formatMiddleRow)
        format_set_align(formatMiddleRow, UInt8((LXW_ALIGN_VERTICAL_TOP).rawValue) )
        format_set_right(formatMiddleRow, 1)
        format_set_left(formatMiddleRow, 1)
        // format_set_top(formatMiddleRow, 1)
        format_set_bottom(formatMiddleRow, 1)
        // format_set_top_color(formatMiddleRow, silver)
        format_set_bottom_color(formatMiddleRow, lxw_color_t(silver))
        format_set_font_size(formatMiddleRow, 10)
        
        // Middle Row Green
        let formatMiddleRowGreen = workbook_add_format(workbook)
        format_set_num_format(formatMiddleRowGreen, "##0")
        format_set_text_wrap(formatMiddleRowGreen)
        format_set_align(formatMiddleRowGreen, UInt8((LXW_ALIGN_VERTICAL_TOP).rawValue) )
        format_set_right(formatMiddleRowGreen, 1)
        format_set_left(formatMiddleRowGreen, 1)
        // format_set_top(formatMiddleRowGreen, 1)
        format_set_bottom(formatMiddleRowGreen, 1)
        // format_set_top_color(formatMiddleRowGreen, silver)
        format_set_bottom_color(formatMiddleRowGreen, lxw_color_t(silver))
        format_set_font_size(formatMiddleRowGreen, 10)
        format_set_font_color(formatMiddleRowGreen, lxw_color_t(green))
        
        
        // Middle Row Double
        let formatMiddleRowDouble = workbook_add_format(workbook)
        // format_set_num_format(formatMiddleRow, "##0")
        format_set_right(formatMiddleRowDouble, 1)
        format_set_left(formatMiddleRowDouble, 1)
        // format_set_top(formatMiddleRowDouble, 1)
        format_set_bottom(formatMiddleRowDouble, 1)
        // format_set_top_color(formatMiddleRowDouble, silver)
        format_set_bottom_color(formatMiddleRowDouble, lxw_color_t(silver))
        format_set_font_size(formatMiddleRowDouble, 10)
        
        
        // Middle Row Centered
        let formatMiddleRowCenter = workbook_add_format(workbook)
        format_set_num_format(formatMiddleRowCenter, "##0")
        format_set_right(formatMiddleRowCenter, 1)
        format_set_left(formatMiddleRowCenter, 1)
        format_set_align(formatMiddleRowCenter, UInt8((LXW_ALIGN_VERTICAL_TOP).rawValue) )
        // format_set_top(formatMiddleRowCenter, 1)
        format_set_bottom(formatMiddleRowCenter, 1)
        // format_set_top_color(formatMiddleRowCenter, silver)
        format_set_bottom_color(formatMiddleRowCenter, lxw_color_t(silver))
        format_set_font_size(formatMiddleRowCenter, 10)
        format_set_align(formatMiddleRowCenter, center)
        
        // Middle Row Centered Green
        let formatMiddleRowCenterGreen = workbook_add_format(workbook)
        format_set_num_format(formatMiddleRowCenterGreen, "##0")
        format_set_right(formatMiddleRowCenterGreen, 1)
        format_set_left(formatMiddleRowCenterGreen, 1)
        format_set_align(formatMiddleRowCenterGreen, UInt8((LXW_ALIGN_VERTICAL_TOP).rawValue) )
        // format_set_top(formatMiddleRowCenterGreen, 1)
        format_set_bottom(formatMiddleRowCenterGreen, 1)
        // format_set_top_color(formatMiddleRowCenter, silver)
        format_set_bottom_color(formatMiddleRowCenterGreen, lxw_color_t(silver))
        format_set_font_size(formatMiddleRowCenterGreen, 10)
        format_set_align(formatMiddleRowCenterGreen, center)
        format_set_font_color(formatMiddleRowCenterGreen, lxw_color_t(green))
        
        
        
        // Middle Row Top Border
        let formatMiddleRowTop = workbook_add_format(workbook)
        format_set_num_format(formatMiddleRowTop, "##0")
        format_set_right(formatMiddleRowTop, 1)
        format_set_left(formatMiddleRowTop, 1)
        format_set_top(formatMiddleRowTop, 1)
        format_set_bottom(formatMiddleRowTop, 1)
        format_set_text_wrap(formatMiddleRowTop)
        // format_set_top_color(formatMiddleRowTop, silver)
        format_set_bottom_color(formatMiddleRowTop, lxw_color_t(silver))
        format_set_font_size(formatMiddleRowTop, 10)
        
        // Bottom Row
        let formatBottomRow = workbook_add_format(workbook)
        format_set_num_format(formatBottomRow, "##0")
        format_set_right(formatBottomRow, 1)
        format_set_left(formatBottomRow, 1)
        format_set_top(formatBottomRow, 1)
        format_set_bottom(formatBottomRow, 1)
        format_set_text_wrap(formatBottomRow)
        format_set_top_color(formatBottomRow, lxw_color_t(silver))
        format_set_font_size(formatBottomRow, 10)
        
        // Bordered Row
        let formatBorderRow = workbook_add_format(workbook)
        format_set_num_format(formatBorderRow, "##0")
        format_set_right(formatBorderRow, 1)
        format_set_left(formatBorderRow, 1)
        format_set_top(formatBorderRow, 1)
        format_set_bottom(formatBorderRow, 1)
        format_set_font_size(formatBorderRow, 10)
        
        // TopLine
        let formatTopLine = workbook_add_format(workbook)
        // format_set_num_format(formatTopLine, "##0")
        // format_set_right(formatTopLine, 1)
        // format_set_left(formatTopLine, 1)
        format_set_top(formatTopLine, 1)
        // format_set_bottom(formatTopLine, 1)
        // format_set_font_size(formatTopLine, 10)
        
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // Ranking
        // Add a worksheet with a user defined sheet name.
        
        var rankings = [Ranking]()
        for cv in cvs {
            rankings.append(Ranking(index: cv.index, name: cv.name, description: cv.shortDescription, rankType: "CV Lower", rank: cv.cvrankl.intValue))
            rankings.append(Ranking(index: cv.index, name: cv.name, description: cv.shortDescription, rankType: "CV Upper", rank: cv.cvranku.intValue))
            if cv.etcwc.intValue > 0 {
                rankings.append(Ranking(index: cv.index, name: cv.name, description: cv.shortDescription, rankType: "ET Lower", rank: cv.etcrl.intValue))
                rankings.append(Ranking(index: cv.index, name: cv.name, description: cv.shortDescription, rankType: "ET Upper", rank: cv.etcru.intValue))
            }
        }
        rankings.sort(){$0.sortVar < $1.sortVar}
        // print(rankings)
        
        
        let worksheet1 = workbook_add_worksheet(workbook, "Ranking")
        worksheet_set_portrait(worksheet1)
        worksheet_set_paper(worksheet1, 3)
        worksheet_set_margins(worksheet1, 0.75, 0.5, 0.5, 0.5)
        // worksheet_fit_to_pages(worksheet1, 1, 1)
        
        let rowOffset = 2
        
        // var col = UInt16(0)
        var row = UInt32(0)
        
        worksheet_write_string(worksheet1, 0, 0, controller.config.controllerName.uppercased() + " Ranking Summary", formatTitle)
        
        worksheet_write_string(worksheet1, 1, 0, "CV", formatHeader)
        worksheet_write_string(worksheet1, 1, 1, "Description", formatHeader)
        worksheet_write_string(worksheet1, 1, 2, "Type", formatHeader)
        worksheet_write_string(worksheet1, 1, 3, "Rank", formatHeader)
        row = UInt32(rowOffset)
        
        var lastRank = rankings[0].rank
        var format = formatMiddleRow
        
        for rank in rankings {
            if rank.rank == lastRank {
                format = formatMiddleRow
            } else {
                format = formatMiddleRowTop
            }
            worksheet_write_string(worksheet1, row, 0, rank.name, format)
            worksheet_write_string(worksheet1, row, 1, rank.description, format)
            worksheet_write_string(worksheet1, row, 2, rank.rankType, format)
            worksheet_write_number(worksheet1, row, 3, Double(rank.rank), format)
            lastRank = rank.rank
            row += 1
        }
        
        // Bottom Line
        worksheet_write_string(worksheet1, row, 0, "", formatTopLine)
        worksheet_write_string(worksheet1, row, 1, "", formatTopLine)
        worksheet_write_string(worksheet1, row, 2, "", formatTopLine)
        worksheet_write_string(worksheet1, row, 3, "", formatTopLine)
        
        // Set Column Widths
        worksheet_set_column(worksheet1, 3, 0, 12.0, nil)
        worksheet_set_column(worksheet1, 3, 1, 22.0, nil)
        worksheet_set_column(worksheet1, 3, 2, 10.0, nil)
        worksheet_set_column(worksheet1, 3, 3, 8.0, nil)
        
        
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // Design
        // Add a worksheet with a user defined sheet name.
        let worksheet2 = workbook_add_worksheet(workbook, "Design")
        worksheet_set_portrait(worksheet2)
        worksheet_set_paper(worksheet2, 2)
        worksheet_set_margins(worksheet2, 0.75, 0.5, 0.5, 0.5)
        // worksheet_fit_to_pages(worksheet2, 1, 1)
        
        
        
        worksheet_write_string(worksheet2, 0, 0, controller.config.controllerName.uppercased() + " Design", formatTitle)
        
        // Mvs
        row = UInt32(rowOffset)
        worksheet_write_string(worksheet2, row, 0, "MVs", formatTitle)
        row += 1
        
        worksheet_write_string(worksheet2, row, 0, "No", formatHeader)
        worksheet_write_string(worksheet2, row, 1, "Tag", formatHeader)
        worksheet_write_string(worksheet2, row, 2, "Description", formatHeader)
        worksheet_write_string(worksheet2, row, 3, "Units", formatHeader)
        worksheet_write_string(worksheet2, row, 4, "Critical", formatHeader)
        
        format = formatMiddleRow
        row += 1
        
        for mv in mvs {
            worksheet_write_number(worksheet2, row, 0, Double(mv.index + 1), formatMiddleRowCenter)
            worksheet_write_string(worksheet2, row, 1, mv.name, format)
            worksheet_write_string(worksheet2, row, 2, mv.shortDescription, format)
            worksheet_write_string(worksheet2, row, 3, mv.engind.value, format)
            if mv.criind.intValue > 0 {
                worksheet_write_string(worksheet2, row, 4, "X", formatMiddleRowCenter)
            } else {
                worksheet_write_string(worksheet2, row, 4, "", format)
            }
            row += 1
        }
        // Bottom Line
        worksheet_write_string(worksheet2, row, 0, "", formatTopLine)
        worksheet_write_string(worksheet2, row, 1, "", formatTopLine)
        worksheet_write_string(worksheet2, row, 2, "", formatTopLine)
        worksheet_write_string(worksheet2, row, 3, "", formatTopLine)
        worksheet_write_string(worksheet2, row, 4, "", formatTopLine)
        
        // FFs
        row += 1
        worksheet_write_string(worksheet2, row, 0, "FFs", formatTitle)
        row += 1
        
        worksheet_write_string(worksheet2, row, 0, "No", formatHeader)
        worksheet_write_string(worksheet2, row, 1, "Tag", formatHeader)
        worksheet_write_string(worksheet2, row, 2, "Description", formatHeader)
        worksheet_write_string(worksheet2, row, 3, "Units", formatHeader)
        worksheet_write_string(worksheet2, row, 4, "Critical", formatHeader)
        row += 1
        
        
        for ff in ffs {
            worksheet_write_number(worksheet2, row, 0, Double(ff.index + 1), formatMiddleRowCenter)
            worksheet_write_string(worksheet2, row, 1, ff.name, formatMiddleRow)
            worksheet_write_string(worksheet2, row, 2, ff.shortDescription, formatMiddleRow)
            worksheet_write_string(worksheet2, row, 3, ff.engind.value, formatMiddleRow)
            if ff.criind.intValue > 0 {
                worksheet_write_string(worksheet2, row, 4, "X", formatMiddleRowCenter)
            } else {
                worksheet_write_string(worksheet2, row, 4, "", formatMiddleRow)
            }
            row += 1
        }
        
        // Bottom Line
        worksheet_write_string(worksheet2, row, 0, "", formatTopLine)
        worksheet_write_string(worksheet2, row, 1, "", formatTopLine)
        worksheet_write_string(worksheet2, row, 2, "", formatTopLine)
        worksheet_write_string(worksheet2, row, 3, "", formatTopLine)
        worksheet_write_string(worksheet2, row, 4, "", formatTopLine)
        
        // Cvs
        row += 1
        worksheet_write_string(worksheet2, row, 0, "CVs", formatTitle)
        row += 1
        
        worksheet_write_string(worksheet2, row, 0, "No", formatHeader)
        worksheet_write_string(worksheet2, row, 1, "Tag", formatHeader)
        worksheet_write_string(worksheet2, row, 2, "Description", formatHeader)
        worksheet_write_string(worksheet2, row, 3, "Units", formatHeader)
        worksheet_write_string(worksheet2, row, 4, "Critical", formatHeader)
        row += 1
        
        
        for cv in cvs {
            worksheet_write_number(worksheet2, row, 0, Double(cv.index + 1), formatMiddleRowCenter)
            worksheet_write_string(worksheet2, row, 1, cv.name, formatMiddleRow)
            worksheet_write_string(worksheet2, row, 2, cv.shortDescription, formatMiddleRow)
            worksheet_write_string(worksheet2, row, 3, cv.engdep.value, formatMiddleRow)
            if cv.cridep.intValue > 0 {
                worksheet_write_string(worksheet2, row, 4, "X", formatMiddleRowCenter)
            } else {
                worksheet_write_string(worksheet2, row, 4, "", formatMiddleRow)
            }
            row += 1
        }
        
        // Bottom Line
        worksheet_write_string(worksheet2, row, 0, "", formatTopLine)
        worksheet_write_string(worksheet2, row, 1, "", formatTopLine)
        worksheet_write_string(worksheet2, row, 2, "", formatTopLine)
        worksheet_write_string(worksheet2, row, 3, "", formatTopLine)
        worksheet_write_string(worksheet2, row, 4, "", formatTopLine)
        
        // Set Column Widths
        worksheet_set_column(worksheet2, 5, 0, 3.0, nil)
        worksheet_set_column(worksheet2, 5, 1, 12.0, nil)
        worksheet_set_column(worksheet2, 5, 2, 22.0, nil)
        worksheet_set_column(worksheet2, 5, 3, 10.0, nil)
        worksheet_set_column(worksheet2, 5, 4, 6.0, nil)
        
        
        
        
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // Model Variables
        // Add a worksheet with a user defined sheet name.
        let worksheet3 = workbook_add_worksheet(workbook, "ModelVars")
        worksheet_set_portrait(worksheet3)
        worksheet_set_paper(worksheet3, 3)
        worksheet_set_margins(worksheet3, 0.75, 0.5, 0.5, 0.5)
        // worksheet_fit_to_pages(worksheet3, 1, 1)
        
        
        worksheet_write_string(worksheet3, 0, 0, controller.config.controllerName.uppercased() + " Model Variables", formatTitle)
        
        // Inds
        row = UInt32(rowOffset)
        worksheet_write_string(worksheet3, row, 0, "Inds", formatTitle)
        row += 1
        
        worksheet_write_string(worksheet3, row, 0, "No", formatHeader)
        worksheet_write_string(worksheet3, row, 1, "Tag", formatHeader)
        worksheet_write_string(worksheet3, row, 2, "Description", formatHeader)
        worksheet_write_string(worksheet3, row, 3, "Units", formatHeader)
        worksheet_write_string(worksheet3, row, 4, "Critical", formatHeader)
        worksheet_write_string(worksheet3, row, 5, "Typ Move", formatHeader)
        
        format = formatMiddleRow
        row += 1
        
        for mv in mvs {
            worksheet_write_number(worksheet3, row, 0, Double(mv.index + 1), formatMiddleRowCenter)
            worksheet_write_string(worksheet3, row, 1, mv.name, format)
            worksheet_write_string(worksheet3, row, 2, mv.shortDescription, format)
            worksheet_write_string(worksheet3, row, 3, mv.engind.value, format)
            if mv.cridep.intValue > 0 {
                worksheet_write_string(worksheet3, row, 4, "X", formatMiddleRowCenter)
            } else {
                worksheet_write_string(worksheet3, row, 4, "", format)
            }
            let typicalMove = controller.model.inds[mv.index].typicalMove
            worksheet_write_number(worksheet3, row, 5, typicalMove, formatMiddleRowDouble)
            row += 1
        }
        
        for ff in ffs {
            worksheet_write_number(worksheet3, row, 0, Double(ff.index + 1), formatMiddleRowCenter)
            worksheet_write_string(worksheet3, row, 1, ff.name, formatMiddleRow)
            worksheet_write_string(worksheet3, row, 2, ff.shortDescription, formatMiddleRow)
            worksheet_write_string(worksheet3, row, 3, ff.engind.value, formatMiddleRow)
            if ff.criind.intValue > 0 {
                worksheet_write_string(worksheet3, row, 4, "X", formatMiddleRowCenter)
            } else {
                worksheet_write_string(worksheet3, row, 4, "", formatMiddleRow)
            }
            print("mv.count \(mvs.count)  ff.index \(ff.index)  calc \(mvs.count - 1)")
            let typicalMove = controller.model.inds[mvs.count - 1].typicalMove
            worksheet_write_number(worksheet3, row, 5, typicalMove, formatMiddleRowDouble)
            row += 1
        }
        
        // Bottom Line
        worksheet_write_string(worksheet3, row, 0, "", formatTopLine)
        worksheet_write_string(worksheet3, row, 1, "", formatTopLine)
        worksheet_write_string(worksheet3, row, 2, "", formatTopLine)
        worksheet_write_string(worksheet3, row, 3, "", formatTopLine)
        worksheet_write_string(worksheet3, row, 4, "", formatTopLine)
        worksheet_write_string(worksheet3, row, 5, "", formatTopLine)
        
        
        // Deps
        row += 1
        worksheet_write_string(worksheet3, row, 0, "Deps", formatTitle)
        row += 1
        
        worksheet_write_string(worksheet3, row, 0, "No", formatHeader)
        worksheet_write_string(worksheet3, row, 1, "Tag", formatHeader)
        worksheet_write_string(worksheet3, row, 2, "Description", formatHeader)
        worksheet_write_string(worksheet3, row, 3, "Units", formatHeader)
        worksheet_write_string(worksheet3, row, 4, "Critical", formatHeader)
        worksheet_write_string(worksheet3, row, 5, "Max Gain", formatHeader)
        row += 1
        
        
        for cv in cvs {
            worksheet_write_number(worksheet3, row, 0, Double(cv.index + 1), formatMiddleRowCenter)
            worksheet_write_string(worksheet3, row, 1, cv.name, formatMiddleRow)
            worksheet_write_string(worksheet3, row, 2, cv.shortDescription, formatMiddleRow)
            worksheet_write_string(worksheet3, row, 3, cv.engdep.value, formatMiddleRow)
            if cv.cridep.intValue > 0 {
                worksheet_write_string(worksheet3, row, 4, "X", formatMiddleRowCenter)
            } else {
                worksheet_write_string(worksheet3, row, 4, "", formatMiddleRow)
            }
            let gainWindow = controller.model.deps[cv.index].gainWindow
            worksheet_write_number(worksheet3, row, 5, gainWindow, formatMiddleRowDouble)
            row += 1
        }
        
        // Bottom Line
        worksheet_write_string(worksheet3, row, 0, "", formatTopLine)
        worksheet_write_string(worksheet3, row, 1, "", formatTopLine)
        worksheet_write_string(worksheet3, row, 2, "", formatTopLine)
        worksheet_write_string(worksheet3, row, 3, "", formatTopLine)
        worksheet_write_string(worksheet3, row, 4, "", formatTopLine)
        worksheet_write_string(worksheet3, row, 5, "", formatTopLine)
        
        // Set Column Widths
        worksheet_set_column(worksheet3, 4, 0, 3.0, nil)
        worksheet_set_column(worksheet3, 4, 1, 12.0, nil)
        worksheet_set_column(worksheet3, 4, 2, 22.0, nil)
        worksheet_set_column(worksheet3, 4, 3, 10.0, nil)
        worksheet_set_column(worksheet3, 4, 4, 6.0, nil)
        worksheet_set_column(worksheet3, 4, 5, 8.0, nil)
        
        
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // Eng Limits
        // Add a worksheet with a user defined sheet name.
        let worksheet22 = workbook_add_worksheet(workbook, "EngLimits")
        worksheet_set_portrait(worksheet2)
        worksheet_set_paper(worksheet2, 2)
        worksheet_set_margins(worksheet2, 0.75, 0.5, 0.5, 0.5)
        // worksheet_fit_to_pages(worksheet2, 1, 1)
        
        
        
        worksheet_write_string(worksheet22, 0, 0, controller.config.controllerName.uppercased() + " Engineering Lmits", formatTitle)
        
        // Mvs
        row = UInt32(rowOffset)
        worksheet_write_string(worksheet22, row, 0, "MVs", formatTitle)
        row += 1
        
        worksheet_write_string(worksheet22, row, 0, "No", formatHeader)
        worksheet_write_string(worksheet22, row, 1, "Tag", formatHeader)
        worksheet_write_string(worksheet22, row, 2, "Description", formatHeader)
        worksheet_write_string(worksheet22, row, 3, "Lower", formatHeader)
        worksheet_write_string(worksheet22, row, 4, "Upper", formatHeader)
        
        format = formatMiddleRow
        row += 1
        
        for mv in mvs {
            worksheet_write_number(worksheet22, row, 0, Double(mv.index + 1), formatMiddleRowCenter)
            worksheet_write_string(worksheet22, row, 1, mv.name, format)
            worksheet_write_string(worksheet22, row, 2, mv.shortDescription, format)
            worksheet_write_string(worksheet22, row, 3, mv.lmveng.value, format)
            worksheet_write_string(worksheet22, row, 4, mv.umveng.value, format)
           row += 1
        }
        // Bottom Line
        worksheet_write_string(worksheet22, row, 0, "", formatTopLine)
        worksheet_write_string(worksheet22, row, 1, "", formatTopLine)
        worksheet_write_string(worksheet22, row, 2, "", formatTopLine)
        worksheet_write_string(worksheet22, row, 3, "", formatTopLine)
        worksheet_write_string(worksheet22, row, 4, "", formatTopLine)
        
        
        // Cvs
        row += 1
        worksheet_write_string(worksheet22, row, 0, "CVs", formatTitle)
        row += 1
        
        worksheet_write_string(worksheet22, row, 0, "No", formatHeader)
        worksheet_write_string(worksheet22, row, 1, "Tag", formatHeader)
        worksheet_write_string(worksheet22, row, 2, "Description", formatHeader)
        worksheet_write_string(worksheet22, row, 3, "Lower", formatHeader)
        worksheet_write_string(worksheet22, row, 4, "Upper", formatHeader)
        row += 1
        
        
        for cv in cvs {
            worksheet_write_number(worksheet22, row, 0, Double(cv.index + 1), formatMiddleRowCenter)
            worksheet_write_string(worksheet22, row, 1, cv.name, formatMiddleRow)
            worksheet_write_string(worksheet22, row, 2, cv.shortDescription, formatMiddleRow)
            worksheet_write_string(worksheet22, row, 3, cv.ldpeng.value, formatMiddleRow)
            worksheet_write_string(worksheet22, row, 3, cv.updeng.value, formatMiddleRow)
            row += 1
        }
        
        // Bottom Line
        worksheet_write_string(worksheet22, row, 0, "", formatTopLine)
        worksheet_write_string(worksheet22, row, 1, "", formatTopLine)
        worksheet_write_string(worksheet22, row, 2, "", formatTopLine)
        worksheet_write_string(worksheet22, row, 3, "", formatTopLine)
        worksheet_write_string(worksheet22, row, 4, "", formatTopLine)
        
        // Set Column Widths
        worksheet_set_column(worksheet22, 5, 0, 3.0, nil)
        worksheet_set_column(worksheet22, 5, 1, 12.0, nil)
        worksheet_set_column(worksheet22, 5, 2, 22.0, nil)
        worksheet_set_column(worksheet22, 5, 3, 10.0, nil)
        worksheet_set_column(worksheet22, 5, 4, 10.0, nil)
        
        

        
        
        
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // Mv Tuning
        // Add a worksheet with a user defined sheet name.
        let worksheet4 = workbook_add_worksheet(workbook, "MVTuning")
        worksheet_set_portrait(worksheet4)
        worksheet_set_paper(worksheet1, 3)
        worksheet_set_margins(worksheet4, 0.75, 0.5, 0.5, 0.5)
        // worksheet_fit_to_pages(worksheet4, 1, 1)
        
        worksheet_write_string(worksheet4, 0, 0, controller.config.controllerName.uppercased() + " MV Tuning", formatTitle)
        // format_set_num_format(formatMiddleRow, "##0.000")
        
        row = UInt32(rowOffset - 1)
        
        worksheet_write_string(worksheet4, row, 0, "No", formatHeader)
        worksheet_write_string(worksheet4, row, 1, "Tag", formatHeader)
        worksheet_write_string(worksheet4, row, 2, "Description", formatHeader)
        worksheet_write_string(worksheet4, row, 3, "Move\nSupr", formatHeader)
        worksheet_write_string(worksheet4, row, 4, "Cost", formatHeader)
        worksheet_write_string(worksheet4, row, 5, "Max\nMove", formatHeader)
        worksheet_write_string(worksheet4, row, 6, "SS\nStep", formatHeader)
        worksheet_write_string(worksheet4, row, 7, "MSupr\nMult", formatHeader)
        worksheet_write_string(worksheet4, row, 8, "Track", formatHeader)
        
        row += 1
        
        for mv in mvs {
            worksheet_write_number(worksheet4, row, 0, Double(mv.index + 1), formatMiddleRowCenter)
            worksheet_write_string(worksheet4, row, 1, mv.name, formatMiddleRow)
            worksheet_write_string(worksheet4, row, 2, mv.shortDescription, formatMiddleRow)
            worksheet_write_number(worksheet4, row, 3, mv.supmov.doubleValue, formatMiddleRowDouble)
            var lpcrit = "M"
            if mv.lpcrit.intValue == 0 {
                lpcrit = "C"
            }
            worksheet_write_string(worksheet4, row, 4, "\(lpcrit) / \(mv.cst.doubleValue)", formatMiddleRowCenter)
            worksheet_write_number(worksheet4, row, 5, mv.maxmov.doubleValue, formatMiddleRowDouble)
            worksheet_write_number(worksheet4, row, 6, mv.ssstep.doubleValue, formatMiddleRowDouble)
            if mv.supmlt.doubleValue < 1.0 {
                worksheet_write_number(worksheet4, row, 7, 2.0, formatMiddleRowDouble)
            } else {
                worksheet_write_number(worksheet4, row, 7, mv.supmlt.doubleValue, formatMiddleRowDouble)
            }
            if mv.trkman.intValue > 0 {
                worksheet_write_string(worksheet4, row, 8, "X", formatMiddleRowCenter)
            } else {
                worksheet_write_string(worksheet4, row, 8, "", formatMiddleRowCenter)
            }
            row += 1
        }
        // Bottom Line
        worksheet_write_string(worksheet4, row, 0, "", formatTopLine)
        worksheet_write_string(worksheet4, row, 1, "", formatTopLine)
        worksheet_write_string(worksheet4, row, 2, "", formatTopLine)
        worksheet_write_string(worksheet4, row, 3, "", formatTopLine)
        worksheet_write_string(worksheet4, row, 4, "", formatTopLine)
        worksheet_write_string(worksheet4, row, 5, "", formatTopLine)
        worksheet_write_string(worksheet4, row, 6, "", formatTopLine)
        worksheet_write_string(worksheet4, row, 7, "", formatTopLine)
        worksheet_write_string(worksheet4, row, 8, "", formatTopLine)
        
        // Set Column Widths
        worksheet_set_column(worksheet4, 4, 0, 3.0, nil)
        worksheet_set_column(worksheet4, 4, 1, 12.0, nil)
        worksheet_set_column(worksheet4, 4, 2, 22.0, nil)
        worksheet_set_column(worksheet4, 4, 3, 8.0, nil)
        worksheet_set_column(worksheet4, 4, 4, 13.0, nil)
        worksheet_set_column(worksheet4, 4, 5, 8.0, nil)
        worksheet_set_column(worksheet4, 4, 6, 8.0, nil)
        worksheet_set_column(worksheet4, 4, 7, 6.0, nil)
        worksheet_set_column(worksheet4, 4, 8, 6.0, nil)
        
        
        
        
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // MV Limits
        // Add a worksheet with a user defined sheet name.
        let worksheet5 = workbook_add_worksheet(workbook, "MVLimits")
        worksheet_set_portrait(worksheet5)
        worksheet_set_paper(worksheet5, 3)
        worksheet_set_margins(worksheet5, 0.75, 0.5, 0.5, 0.5)
        // worksheet_fit_to_pages(worksheet5, 1, 1)
        
        worksheet_write_string(worksheet5, 0, 0, controller.config.controllerName.uppercased() + " MV Limits", formatTitle)
        
        // Mvs
        row = UInt32(rowOffset - 1)
        
        worksheet_write_string(worksheet5, row, 0, "", formatHeaderUpper)
        worksheet_write_string(worksheet5, row, 1, "", formatHeaderUpper)
        worksheet_write_string(worksheet5, row, 2, "", formatHeaderUpper)
        worksheet_write_string(worksheet5, row, 3, "      Operating Limits", formatHeaderLeftTop)
        worksheet_write_string(worksheet5, row, 4, "", formatHeaderRightTop)
        worksheet_write_string(worksheet5, row, 5, "      Engineering Limits", formatHeaderLeftTop)
        worksheet_write_string(worksheet5, row, 6, "", formatHeaderRightTop)
        worksheet_write_string(worksheet5, row, 7, "          Valid Limits", formatHeaderLeftTop)
        worksheet_write_string(worksheet5, row, 8, "", formatHeaderRightTop)
        row += 1
        
        worksheet_write_string(worksheet5, row, 0, "No", formatHeaderLower)
        worksheet_write_string(worksheet5, row, 1, "Tag", formatHeaderLower)
        worksheet_write_string(worksheet5, row, 2, "Description", formatHeaderLower)
        worksheet_write_string(worksheet5, row, 3, "Lower", formatHeader)
        worksheet_write_string(worksheet5, row, 4, "Upper", formatHeader)
        worksheet_write_string(worksheet5, row, 5, "Lower", formatHeader)
        worksheet_write_string(worksheet5, row, 6, "Upper", formatHeader)
        worksheet_write_string(worksheet5, row, 7, "Lower", formatHeader)
        worksheet_write_string(worksheet5, row, 8, "Upper", formatHeader)
        
        row += 1
        
        for mv in mvs {
            worksheet_write_number(worksheet5, row, 0, Double(mv.index + 1), formatMiddleRowCenter)
            worksheet_write_string(worksheet5, row, 1, mv.name, formatMiddleRow)
            worksheet_write_string(worksheet5, row, 2, mv.shortDescription, formatMiddleRow)
            worksheet_write_number(worksheet5, row, 3, mv.llindm.doubleValue, formatMiddleRowDouble)
            worksheet_write_number(worksheet5, row, 4, mv.ulindm.doubleValue, formatMiddleRowDouble)
            worksheet_write_number(worksheet5, row, 5, mv.lmveng.doubleValue, formatMiddleRowDouble)
            worksheet_write_number(worksheet5, row, 6, mv.umveng.doubleValue, formatMiddleRowDouble)
            worksheet_write_number(worksheet5, row, 7, mv.lvlind.doubleValue, formatMiddleRowDouble)
            worksheet_write_number(worksheet5, row, 8, mv.uvlind.doubleValue, formatMiddleRowDouble)
            
            row += 1
        }
        // Bottom Line
        worksheet_write_string(worksheet5, row, 0, "", formatTopLine)
        worksheet_write_string(worksheet5, row, 1, "", formatTopLine)
        worksheet_write_string(worksheet5, row, 2, "", formatTopLine)
        worksheet_write_string(worksheet5, row, 3, "", formatTopLine)
        worksheet_write_string(worksheet5, row, 4, "", formatTopLine)
        worksheet_write_string(worksheet5, row, 5, "", formatTopLine)
        worksheet_write_string(worksheet5, row, 6, "", formatTopLine)
        worksheet_write_string(worksheet5, row, 7, "", formatTopLine)
        worksheet_write_string(worksheet5, row, 8, "", formatTopLine)
        
        // Set Column Widths
        worksheet_set_column(worksheet5, 4, 0, 3.0, nil)
        worksheet_set_column(worksheet5, 4, 1, 12.0, nil)
        worksheet_set_column(worksheet5, 4, 2, 22.0, nil)
        worksheet_set_column(worksheet5, 4, 3, 8.0, nil)
        worksheet_set_column(worksheet5, 4, 4, 8.0, nil)
        worksheet_set_column(worksheet5, 4, 5, 8.0, nil)
        worksheet_set_column(worksheet5, 4, 6, 8.0, nil)
        worksheet_set_column(worksheet5, 4, 7, 8.0, nil)
        worksheet_set_column(worksheet5, 4, 8, 8.0, nil)
        
        
        
        
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // FF Limits
        // Add a worksheet with a user defined sheet name.
        let worksheet6 = workbook_add_worksheet(workbook, "FFLimits")
        worksheet_set_portrait(worksheet6)
        worksheet_set_paper(worksheet6, 3)
        worksheet_set_margins(worksheet6, 0.75, 0.5, 0.5, 0.5)
        // worksheet_fit_to_pages(worksheet6, 1, 1)
        
        worksheet_write_string(worksheet6, 0, 0, controller.config.controllerName.uppercased() + " FF Limits", formatTitle)
        
        row = UInt32(rowOffset - 1)
        
        worksheet_write_string(worksheet6, row, 0, "", formatHeaderUpper)
        worksheet_write_string(worksheet6, row, 1, "", formatHeaderUpper)
        worksheet_write_string(worksheet6, row, 2, "", formatHeaderUpper)
        worksheet_write_string(worksheet6, row, 3, "          Valid Limits", formatHeaderLeftTop)
        worksheet_write_string(worksheet6, row, 4, "", formatHeaderRightTop)
        row += 1
        
        worksheet_write_string(worksheet6, row, 0, "No", formatHeaderLower)
        worksheet_write_string(worksheet6, row, 1, "Tag", formatHeaderLower)
        worksheet_write_string(worksheet6, row, 2, "Description", formatHeaderLower)
        worksheet_write_string(worksheet6, row, 3, "Lower", formatHeader)
        worksheet_write_string(worksheet6, row, 4, "Upper", formatHeader)
        
        row += 1
        
        for ff in ffs {
            worksheet_write_number(worksheet6, row, 0, Double(ff.index + 1), formatMiddleRowCenter)
            worksheet_write_string(worksheet6, row, 1, ff.name, formatMiddleRow)
            worksheet_write_string(worksheet6, row, 2, ff.shortDescription, formatMiddleRow)
            worksheet_write_number(worksheet6, row, 3, ff.lvlind.doubleValue, formatMiddleRowDouble)
            worksheet_write_number(worksheet6, row, 4, ff.uvlind.doubleValue, formatMiddleRowDouble)
            
            row += 1
        }
        // Bottom Line
        worksheet_write_string(worksheet6, row, 0, "", formatTopLine)
        worksheet_write_string(worksheet6, row, 1, "", formatTopLine)
        worksheet_write_string(worksheet6, row, 2, "", formatTopLine)
        worksheet_write_string(worksheet6, row, 3, "", formatTopLine)
        worksheet_write_string(worksheet6, row, 4, "", formatTopLine)
        
        // Set Column Widths
        worksheet_set_column(worksheet6, 4, 0, 3.0, nil)
        worksheet_set_column(worksheet6, 4, 1, 12.0, nil)
        worksheet_set_column(worksheet6, 4, 2, 22.0, nil)
        worksheet_set_column(worksheet6, 4, 3, 8.0, nil)
        worksheet_set_column(worksheet6, 4, 4, 8.0, nil)
        
        
        
        
        
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // CV SS Tuning
        // Add a worksheet with a user defined sheet name.
        let worksheet7 = workbook_add_worksheet(workbook, "CVSSTuning")
        worksheet_set_portrait(worksheet7)
        worksheet_set_paper(worksheet7, 3)
        worksheet_set_margins(worksheet7, 0.75, 0.5, 0.5, 0.5)
        // worksheet_fit_to_pages(worksheet7, 1, 1)
        
        worksheet_write_string(worksheet7, 0, 0, controller.config.controllerName.uppercased() + " CV SS Tuning", formatTitle)
        
        row = UInt32(rowOffset - 1)
        
        worksheet_write_string(worksheet7, row, 0, "", formatHeaderUpper)
        worksheet_write_string(worksheet7, row, 1, "", formatHeaderUpper)
        worksheet_write_string(worksheet7, row, 2, "", formatHeaderUpper)
        worksheet_write_string(worksheet7, row, 3, "                 Rank", formatHeaderLeftTop)
        worksheet_write_string(worksheet7, row, 4, "", formatHeaderRightTop)
        worksheet_write_string(worksheet7, row, 5, "Rank", formatHeaderUpper)
        worksheet_write_string(worksheet7, row, 6, "                 SS ECE", formatHeaderLeftTop)
        worksheet_write_string(worksheet7, row, 7, "", formatHeaderRightTop)
        worksheet_write_string(worksheet7, row, 8, "Max", formatHeaderUpper)
        worksheet_write_string(worksheet7, row, 9, "", formatHeaderUpper)
        row += 1
        
        worksheet_write_string(worksheet7, row, 0, "No", formatHeaderLower)
        worksheet_write_string(worksheet7, row, 1, "Tag", formatHeaderLower)
        worksheet_write_string(worksheet7, row, 2, "Description", formatHeaderLower)
        worksheet_write_string(worksheet7, row, 3, "Lower", formatHeader)
        worksheet_write_string(worksheet7, row, 4, "Upper", formatHeader)
        worksheet_write_string(worksheet7, row, 5, "Type", formatHeaderLower)
        worksheet_write_string(worksheet7, row, 6, "Lower", formatHeader)
        worksheet_write_string(worksheet7, row, 7, "Upper", formatHeader)
        worksheet_write_string(worksheet7, row, 8, "SS Step", formatHeaderLower)
        worksheet_write_string(worksheet7, row, 9, "Track", formatHeaderLower)
        
        row += 1
        
        for cv in cvs {
            worksheet_write_number(worksheet7, row, 0, Double(cv.index + 1), formatMiddleRowCenter)
            worksheet_write_string(worksheet7, row, 1, cv.name, formatMiddleRow)
            worksheet_write_string(worksheet7, row, 2, cv.shortDescription, formatMiddleRow)
            worksheet_write_number(worksheet7, row, 3, cv.cvrankl.doubleValue, formatMiddleRowDouble)
            worksheet_write_number(worksheet7, row, 4, cv.cvranku.doubleValue, formatMiddleRowDouble)
            var lowSolnType = "L"
            if cv.cvlpql.intValue > 0 {
                lowSolnType = "Q"
            }
            var highSolnType = "L"
            if cv.cvlpqu.intValue > 0 {
                highSolnType = "Q"
            }
            worksheet_write_string(worksheet7, row, 5, lowSolnType + highSolnType, formatMiddleRowCenter)
            worksheet_write_number(worksheet7, row, 6, cv.ecelpl.doubleValue, formatMiddleRowDouble)
            worksheet_write_number(worksheet7, row, 7, cv.ecelpu.doubleValue, formatMiddleRowDouble)
            worksheet_write_number(worksheet7, row, 8, cv.cvstep.doubleValue, formatMiddleRowDouble)
            if cv.trkdep.intValue > 0 {
                worksheet_write_string(worksheet7, row, 9, "X", formatMiddleRowCenter)
            } else {
                worksheet_write_string(worksheet7, row, 9, "", formatMiddleRowCenter)
            }
            
            row += 1
        }
        // Bottom Line
        worksheet_write_string(worksheet7, row, 0, "", formatTopLine)
        worksheet_write_string(worksheet7, row, 1, "", formatTopLine)
        worksheet_write_string(worksheet7, row, 2, "", formatTopLine)
        worksheet_write_string(worksheet7, row, 3, "", formatTopLine)
        worksheet_write_string(worksheet7, row, 4, "", formatTopLine)
        worksheet_write_string(worksheet7, row, 5, "", formatTopLine)
        worksheet_write_string(worksheet7, row, 6, "", formatTopLine)
        worksheet_write_string(worksheet7, row, 7, "", formatTopLine)
        worksheet_write_string(worksheet7, row, 8, "", formatTopLine)
        worksheet_write_string(worksheet7, row, 9, "", formatTopLine)
        
        // Set Column Widths
        worksheet_set_column(worksheet7, 4, 0, 3.0, nil)
        worksheet_set_column(worksheet7, 4, 1, 12.0, nil)
        worksheet_set_column(worksheet7, 4, 2, 22.0, nil)
        worksheet_set_column(worksheet7, 4, 3, 8.0, nil)
        worksheet_set_column(worksheet7, 4, 4, 8.0, nil)
        worksheet_set_column(worksheet7, 4, 5, 8.0, nil)
        worksheet_set_column(worksheet7, 4, 6, 8.0, nil)
        worksheet_set_column(worksheet7, 4, 7, 8.0, nil)
        worksheet_set_column(worksheet7, 4, 8, 8.0, nil)
        worksheet_set_column(worksheet7, 4, 9, 8.0, nil)
        
        
        
        
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // CV ECE Tuning
        // Add a worksheet with a user defined sheet name.
        let worksheet8 = workbook_add_worksheet(workbook, "ECETuning")
        worksheet_set_portrait(worksheet8)
        worksheet_set_paper(worksheet8, 3)
        worksheet_set_margins(worksheet8, 0.75, 0.5, 0.5, 0.5)
        // worksheet_fit_to_pages(worksheet8, 1, 1)
        
        worksheet_write_string(worksheet8, 0, 0, controller.config.controllerName.uppercased() + " CV ECE Tuning", formatTitle)
        
        row = UInt32(rowOffset - 1)
        
        worksheet_write_string(worksheet8, row, 0, "", formatHeaderUpper)
        worksheet_write_string(worksheet8, row, 1, "", formatHeaderUpper)
        worksheet_write_string(worksheet8, row, 2, "", formatHeaderUpper)
        worksheet_write_string(worksheet8, row, 3, "                SS ECE", formatHeaderLeftTop)
        worksheet_write_string(worksheet8, row, 4, "", formatHeaderLeftTop)
        worksheet_write_string(worksheet8, row, 5, "                     Dynamic ECE", formatHeaderLeftTop)
        worksheet_write_string(worksheet8, row, 6, "", formatTopLine)
        worksheet_write_string(worksheet8, row, 7, "", formatHeaderRightTop)
        worksheet_write_string(worksheet8, row, 8, "       Transition Zone", formatHeaderLeftTop)
        worksheet_write_string(worksheet8, row, 9, "", formatHeaderRightTop)
        row += 1
        
        worksheet_write_string(worksheet8, row, 0, "No", formatHeaderLower)
        worksheet_write_string(worksheet8, row, 1, "Tag", formatHeaderLower)
        worksheet_write_string(worksheet8, row, 2, "Description", formatHeaderLower)
        worksheet_write_string(worksheet8, row, 3, "Lower", formatHeader)
        worksheet_write_string(worksheet8, row, 4, "Upper", formatHeader)
        worksheet_write_string(worksheet8, row, 5, "Lower", formatHeader)
        worksheet_write_string(worksheet8, row, 6, "Middle", formatHeader)
        worksheet_write_string(worksheet8, row, 7, "Upper", formatHeader)
        worksheet_write_string(worksheet8, row, 8, "Lower", formatHeader)
        worksheet_write_string(worksheet8, row, 9, "Upper", formatHeader)
        
        row += 1
        
        for cv in cvs {
            worksheet_write_number(worksheet8, row, 0, Double(cv.index + 1), formatMiddleRowCenter)
            worksheet_write_string(worksheet8, row, 1, cv.name, formatMiddleRow)
            worksheet_write_string(worksheet8, row, 2, cv.shortDescription, formatMiddleRow)
            worksheet_write_number(worksheet8, row, 3, cv.ecelpl.doubleValue, formatMiddleRowDouble)
            worksheet_write_number(worksheet8, row, 4, cv.ecelpu.doubleValue, formatMiddleRowDouble)
            worksheet_write_number(worksheet8, row, 5, cv.ececml.doubleValue, formatMiddleRowCenter)
            worksheet_write_number(worksheet8, row, 6, cv.ececmm.doubleValue, formatMiddleRowDouble)
            worksheet_write_number(worksheet8, row, 7, cv.ececmu.doubleValue, formatMiddleRowDouble)
            worksheet_write_number(worksheet8, row, 8, cv.tranzl.doubleValue, formatMiddleRowDouble)
            worksheet_write_number(worksheet8, row, 9, cv.tranzu.doubleValue, formatMiddleRowDouble)
            
            row += 1
        }
        // Bottom Line
        worksheet_write_string(worksheet8, row, 0, "", formatTopLine)
        worksheet_write_string(worksheet8, row, 1, "", formatTopLine)
        worksheet_write_string(worksheet8, row, 2, "", formatTopLine)
        worksheet_write_string(worksheet8, row, 3, "", formatTopLine)
        worksheet_write_string(worksheet8, row, 4, "", formatTopLine)
        worksheet_write_string(worksheet8, row, 5, "", formatTopLine)
        worksheet_write_string(worksheet8, row, 6, "", formatTopLine)
        worksheet_write_string(worksheet8, row, 7, "", formatTopLine)
        worksheet_write_string(worksheet8, row, 8, "", formatTopLine)
        worksheet_write_string(worksheet8, row, 9, "", formatTopLine)
        
        // Set Column Widths
        worksheet_set_column(worksheet8, 4, 0, 3.0, nil)
        worksheet_set_column(worksheet8, 4, 1, 12.0, nil)
        worksheet_set_column(worksheet8, 4, 2, 22.0, nil)
        worksheet_set_column(worksheet8, 4, 3, 8.0, nil)
        worksheet_set_column(worksheet8, 4, 4, 8.0, nil)
        worksheet_set_column(worksheet8, 4, 5, 8.0, nil)
        worksheet_set_column(worksheet8, 4, 6, 8.0, nil)
        worksheet_set_column(worksheet8, 4, 7, 8.0, nil)
        worksheet_set_column(worksheet8, 4, 8, 8.0, nil)
        worksheet_set_column(worksheet8, 4, 9, 8.0, nil)
        
        
        
        
        
        
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // CV Gain Window (Relative) ECE Tuning
        // Add a worksheet with a user defined sheet name.
        let worksheet9 = workbook_add_worksheet(workbook, "RelECETuning")
        worksheet_set_portrait(worksheet9)
        worksheet_set_paper(worksheet9, 3)
        worksheet_set_margins(worksheet9, 0.75, 0.5, 0.5, 0.5)
        // worksheet_fit_to_pages(worksheet9, 1, 1)
        
        worksheet_write_string(worksheet9, 0, 0, controller.config.controllerName.uppercased() + " CV ECE Tuning", formatTitle)
        
        row = UInt32(rowOffset - 1)
        
        worksheet_write_string(worksheet9, row, 0, "", formatHeaderUpper)
        worksheet_write_string(worksheet9, row, 1, "", formatHeaderUpper)
        worksheet_write_string(worksheet9, row, 2, "", formatHeaderUpper)
        worksheet_write_string(worksheet9, row, 3, "                SS ECE", formatHeaderLeftTop)
        worksheet_write_string(worksheet9, row, 4, "", formatHeaderLeftTop)
        worksheet_write_string(worksheet9, row, 5, "                     Dynamic ECE", formatHeaderLeftTop)
        worksheet_write_string(worksheet9, row, 6, "", formatTopLine)
        worksheet_write_string(worksheet9, row, 7, "", formatHeaderRightTop)
        worksheet_write_string(worksheet9, row, 8, "       Transition Zone", formatHeaderLeftTop)
        worksheet_write_string(worksheet9, row, 9, "", formatHeaderRightTop)
        row += 1
        
        worksheet_write_string(worksheet9, row, 0, "No", formatHeaderLower)
        worksheet_write_string(worksheet9, row, 1, "Tag", formatHeaderLower)
        worksheet_write_string(worksheet9, row, 2, "Description", formatHeaderLower)
        worksheet_write_string(worksheet9, row, 3, "Lower", formatHeader)
        worksheet_write_string(worksheet9, row, 4, "Upper", formatHeader)
        worksheet_write_string(worksheet9, row, 5, "Lower", formatHeader)
        worksheet_write_string(worksheet9, row, 6, "Middle", formatHeader)
        worksheet_write_string(worksheet9, row, 7, "Upper", formatHeader)
        worksheet_write_string(worksheet9, row, 8, "Lower", formatHeader)
        worksheet_write_string(worksheet9, row, 9, "Upper", formatHeader)
        
        row += 1
        // let gainWindow = controller.model.deps[selectedVariable.index].gainWindow
        var relECE = 0.0
        for cv in cvs {
            worksheet_write_number(worksheet9, row, 0, Double(cv.index + 1), formatMiddleRowCenter)
            worksheet_write_string(worksheet9, row, 1, cv.name, formatMiddleRow)
            worksheet_write_string(worksheet9, row, 2, cv.shortDescription, formatMiddleRow)
            if cv.ecelpl.doubleValue >= 1000000.0 {
                relECE = 1000000.0
            } else {
                relECE = cv.ecelpl.doubleValue / controller.model.deps[cv.index].gainWindow
            }
            worksheet_write_number(worksheet9, row, 3, relECE.roundTo(decimalPlaces: 3), formatMiddleRowDouble)
            
            if cv.ecelpu.doubleValue >= 1000000.0 {
                relECE = 1000000.0
            } else {
                relECE = cv.ecelpu.doubleValue / controller.model.deps[cv.index].gainWindow
            }
            worksheet_write_number(worksheet9, row, 4, relECE.roundTo(decimalPlaces: 3), formatMiddleRowDouble)

            if cv.ececml.doubleValue >= 1000000.0 {
                relECE = 1000000.0
            } else {
                relECE = cv.ececml.doubleValue / controller.model.deps[cv.index].gainWindow
            }
            worksheet_write_number(worksheet9, row, 5, relECE.roundTo(decimalPlaces: 3), formatMiddleRowDouble)
 
            if cv.ececmm.doubleValue >= 1000000.0 {
                relECE = 1000000.0
            } else {
                relECE = cv.ececmm.doubleValue / controller.model.deps[cv.index].gainWindow
            }
            worksheet_write_number(worksheet9, row, 6, relECE.roundTo(decimalPlaces: 3), formatMiddleRowDouble)

            if cv.ececmu.doubleValue >= 1000000.0 {
                relECE = 1000000.0
            } else {
                relECE = cv.ececmu.doubleValue / controller.model.deps[cv.index].gainWindow
            }
            worksheet_write_number(worksheet9, row, 7, relECE.roundTo(decimalPlaces: 3), formatMiddleRowDouble)

            relECE = cv.tranzl.doubleValue / controller.model.deps[cv.index].gainWindow
            worksheet_write_number(worksheet9, row, 8, relECE.roundTo(decimalPlaces: 3), formatMiddleRowDouble)
            
            relECE = cv.tranzu.doubleValue / controller.model.deps[cv.index].gainWindow
            worksheet_write_number(worksheet9, row, 9, relECE.roundTo(decimalPlaces: 3), formatMiddleRowDouble)
            
            row += 1
        }
        // Bottom Line
        worksheet_write_string(worksheet9, row, 0, "", formatTopLine)
        worksheet_write_string(worksheet9, row, 1, "", formatTopLine)
        worksheet_write_string(worksheet9, row, 2, "", formatTopLine)
        worksheet_write_string(worksheet9, row, 3, "", formatTopLine)
        worksheet_write_string(worksheet9, row, 4, "", formatTopLine)
        worksheet_write_string(worksheet9, row, 5, "", formatTopLine)
        worksheet_write_string(worksheet9, row, 6, "", formatTopLine)
        worksheet_write_string(worksheet9, row, 7, "", formatTopLine)
        worksheet_write_string(worksheet9, row, 8, "", formatTopLine)
        worksheet_write_string(worksheet9, row, 9, "", formatTopLine)
        
        // Set Column Widths
        worksheet_set_column(worksheet9, 4, 0, 3.0, nil)
        worksheet_set_column(worksheet9, 4, 1, 12.0, nil)
        worksheet_set_column(worksheet9, 4, 2, 22.0, nil)
        worksheet_set_column(worksheet9, 4, 3, 8.0, nil)
        worksheet_set_column(worksheet9, 4, 4, 8.0, nil)
        worksheet_set_column(worksheet9, 4, 5, 8.0, nil)
        worksheet_set_column(worksheet9, 4, 6, 8.0, nil)
        worksheet_set_column(worksheet9, 4, 7, 8.0, nil)
        worksheet_set_column(worksheet9, 4, 8, 8.0, nil)
        worksheet_set_column(worksheet9, 4, 9, 8.0, nil)
        
        
        
        
        
        
        
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // CV Limits
        // Add a worksheet with a user defined sheet name.
        let worksheet10 = workbook_add_worksheet(workbook, "CVLimits")
        worksheet_set_portrait(worksheet10)
        worksheet_set_paper(worksheet10, 3)
        worksheet_set_margins(worksheet10, 0.75, 0.5, 0.5, 0.5)
        // worksheet_fit_to_pages(worksheet9, 1, 1)
        
        worksheet_write_string(worksheet10, 0, 0, controller.config.controllerName.uppercased() + " CV Limits", formatTitle)
        
        // Mvs
        row = UInt32(rowOffset - 1)
        
        worksheet_write_string(worksheet10, row, 0, "", formatHeaderUpper)
        worksheet_write_string(worksheet10, row, 1, "", formatHeaderUpper)
        worksheet_write_string(worksheet10, row, 2, "", formatHeaderUpper)
        worksheet_write_string(worksheet10, row, 3, "      Operating Limits", formatHeaderLeftTop)
        worksheet_write_string(worksheet10, row, 4, "", formatHeaderRightTop)
        worksheet_write_string(worksheet10, row, 5, "      Engineering Limits", formatHeaderLeftTop)
        worksheet_write_string(worksheet10, row, 6, "", formatHeaderRightTop)
        worksheet_write_string(worksheet10, row, 7, "         Valid Limits", formatHeaderLeftTop)
        worksheet_write_string(worksheet10, row, 8, "", formatHeaderRightTop)
        row += 1
        
        worksheet_write_string(worksheet10, row, 0, "No", formatHeaderLower)
        worksheet_write_string(worksheet10, row, 1, "Tag", formatHeaderLower)
        worksheet_write_string(worksheet10, row, 2, "Description", formatHeaderLower)
        worksheet_write_string(worksheet10, row, 3, "Lower", formatHeader)
        worksheet_write_string(worksheet10, row, 4, "Upper", formatHeader)
        worksheet_write_string(worksheet10, row, 5, "Lower", formatHeader)
        worksheet_write_string(worksheet10, row, 6, "Upper", formatHeader)
        worksheet_write_string(worksheet10, row, 7, "Lower", formatHeader)
        worksheet_write_string(worksheet10, row, 8, "Upper", formatHeader)
        
        row += 1
        
        for cv in cvs {
            worksheet_write_number(worksheet10, row, 0, Double(cv.index + 1), formatMiddleRowCenter)
            worksheet_write_string(worksheet10, row, 1, cv.name, formatMiddleRow)
            worksheet_write_string(worksheet10, row, 2, cv.shortDescription, formatMiddleRow)
            worksheet_write_number(worksheet10, row, 3, cv.ldeptg.doubleValue, formatMiddleRowDouble)
            worksheet_write_number(worksheet10, row, 4, cv.udeptg.doubleValue, formatMiddleRowDouble)
            worksheet_write_number(worksheet10, row, 5, cv.ldpeng.doubleValue, formatMiddleRowDouble)
            worksheet_write_number(worksheet10, row, 6, cv.udpeng.doubleValue, formatMiddleRowDouble)
            worksheet_write_number(worksheet10, row, 7, cv.lvldep.doubleValue, formatMiddleRowDouble)
            worksheet_write_number(worksheet10, row, 8, cv.uvldep.doubleValue, formatMiddleRowDouble)
            
            row += 1
        }
        // Bottom Line
        worksheet_write_string(worksheet10, row, 0, "", formatTopLine)
        worksheet_write_string(worksheet10, row, 1, "", formatTopLine)
        worksheet_write_string(worksheet10, row, 2, "", formatTopLine)
        worksheet_write_string(worksheet10, row, 3, "", formatTopLine)
        worksheet_write_string(worksheet10, row, 4, "", formatTopLine)
        worksheet_write_string(worksheet10, row, 5, "", formatTopLine)
        worksheet_write_string(worksheet10, row, 6, "", formatTopLine)
        worksheet_write_string(worksheet10, row, 7, "", formatTopLine)
        worksheet_write_string(worksheet10, row, 8, "", formatTopLine)
        
        // Set Column Widths
        worksheet_set_column(worksheet10, 4, 0, 3.0, nil)
        worksheet_set_column(worksheet10, 4, 1, 12.0, nil)
        worksheet_set_column(worksheet10, 4, 2, 22.0, nil)
        worksheet_set_column(worksheet10, 4, 3, 8.0, nil)
        worksheet_set_column(worksheet10, 4, 4, 8.0, nil)
        worksheet_set_column(worksheet10, 4, 5, 8.0, nil)
        worksheet_set_column(worksheet10, 4, 6, 8.0, nil)
        worksheet_set_column(worksheet10, 4, 7, 8.0, nil)
        worksheet_set_column(worksheet10, 4, 8, 8.0, nil)
        
        
        
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // CV Prediction Filtering
        // Add a worksheet with a user defined sheet name.
        let worksheet11 = workbook_add_worksheet(workbook, "CVFilter")
        worksheet_set_portrait(worksheet11)
        worksheet_set_paper(worksheet11, 3)
        worksheet_set_margins(worksheet11, 0.75, 0.5, 0.5, 0.5)
        // worksheet_fit_to_pages(worksheet10, 1, 1)
        
        worksheet_write_string(worksheet11, 0, 0, controller.config.controllerName.uppercased() + " CV Prediction Filtering", formatTitle)
        
        row = UInt32(rowOffset - 1)
        
        worksheet_write_string(worksheet11, row, 0, "No", formatHeader)
        worksheet_write_string(worksheet11, row, 1, "Tag", formatHeader)
        worksheet_write_string(worksheet11, row, 2, "Description", formatHeader)
        worksheet_write_string(worksheet11, row, 3, "Type", formatHeader)
        worksheet_write_string(worksheet11, row, 4, "Time", formatHeader)
        row += 1
        
        for cv in cvs {
            if cv.prertype.intValue > 0 {
                worksheet_write_number(worksheet11, row, 0, Double(cv.index + 1), formatMiddleRowCenter)
                worksheet_write_string(worksheet11, row, 1, cv.name, formatMiddleRow)
                worksheet_write_string(worksheet11, row, 2, cv.shortDescription, formatMiddleRow)
                var filterType = "DMC"
                var filterTime = 0.0
                if cv.prertype.intValue == 1 {
                    filterType = "First Order"
                    filterTime = cv.prertau.doubleValue
                } else {
                    filterType = "Horizon"
                    filterTime = cv.prerhoriz.doubleValue
                }
                
                worksheet_write_string(worksheet11, row, 3, filterType, formatMiddleRow)
                worksheet_write_number(worksheet11, row, 4, filterTime, formatMiddleRowDouble)
                row += 1
            }
        }
        
        // Bottom Line
        worksheet_write_string(worksheet11, row, 0, "", formatTopLine)
        worksheet_write_string(worksheet11, row, 1, "", formatTopLine)
        worksheet_write_string(worksheet11, row, 2, "", formatTopLine)
        worksheet_write_string(worksheet11, row, 3, "", formatTopLine)
        worksheet_write_string(worksheet11, row, 4, "", formatTopLine)
        
        // Set Column Widths
        worksheet_set_column(worksheet11, 4, 0, 3.0, nil)
        worksheet_set_column(worksheet11, 4, 1, 12.0, nil)
        worksheet_set_column(worksheet11, 4, 2, 22.0, nil)
        worksheet_set_column(worksheet11, 4, 3, 13.0, nil)
        worksheet_set_column(worksheet11, 4, 4, 8.0, nil)
        
        
        
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // CV Ramp Tuning
        // Add a worksheet with a user defined sheet name.
        let worksheet12 = workbook_add_worksheet(workbook, "Ramp")
        worksheet_set_portrait(worksheet12)
        worksheet_set_paper(worksheet12, 3)
        worksheet_set_margins(worksheet12, 0.75, 0.5, 0.5, 0.5)
        // worksheet_fit_to_pages(worksheet11, 1, 1)
        
        worksheet_write_string(worksheet12, 0, 0, controller.config.controllerName.uppercased() + " CV Ramp Tuning", formatTitle)
        
        row = UInt32(rowOffset - 1)
        
        worksheet_write_string(worksheet12, row, 0, "No", formatHeader)
        worksheet_write_string(worksheet12, row, 1, "Tag", formatHeader)
        worksheet_write_string(worksheet12, row, 2, "Description", formatHeader)
        worksheet_write_string(worksheet12, row, 3, "Type", formatHeader)
        worksheet_write_string(worksheet12, row, 4, "Rate", formatHeader)
        worksheet_write_string(worksheet12, row, 5, "Horizen", formatHeader)
        worksheet_write_string(worksheet12, row, 6, "Rotation\nFactor", formatHeader)
        worksheet_write_string(worksheet12, row, 7, "Max\nImbalence", formatHeader)
        worksheet_write_string(worksheet12, row, 8, "Shed\nOption", formatHeader)
        row += 1
        
        for cv in cvs {
            if cv.isramp.intValue > 0 {
                worksheet_write_number(worksheet12, row, 0, Double(cv.index + 1), formatMiddleRowCenter)
                worksheet_write_string(worksheet12, row, 1, cv.name, formatMiddleRow)
                worksheet_write_string(worksheet12, row, 2, cv.shortDescription, formatMiddleRow)
                var rampType = "None"
                if cv.isramp.intValue == 1 {
                    rampType = "Ramp"
                } else {
                    rampType = "Pseudo"
                }
                worksheet_write_string(worksheet12, row, 3, rampType, formatMiddleRow)
                worksheet_write_number(worksheet12, row, 4, cv.ramprt.doubleValue, formatMiddleRowDouble)
                worksheet_write_number(worksheet12, row, 5, cv.rhoriz.doubleValue, formatMiddleRowDouble)
                worksheet_write_number(worksheet12, row, 6, cv.rotfac.doubleValue, formatMiddleRowDouble)
                
                worksheet_write_number(worksheet12, row, 7, cv.mxnimb.doubleValue, formatMiddleRowDouble)
                if cv.rshedsub.intValue == 0 {
                    worksheet_write_string(worksheet12, row, 8, "Main", formatMiddleRow)
                } else {
                    worksheet_write_string(worksheet12, row, 8, "Sub", formatMiddleRow)
                }
                row += 1
            }
        }
        
        // Bottom Line
        worksheet_write_string(worksheet12, row, 0, "", formatTopLine)
        worksheet_write_string(worksheet12, row, 1, "", formatTopLine)
        worksheet_write_string(worksheet12, row, 2, "", formatTopLine)
        worksheet_write_string(worksheet12, row, 3, "", formatTopLine)
        worksheet_write_string(worksheet12, row, 4, "", formatTopLine)
        worksheet_write_string(worksheet12, row, 5, "", formatTopLine)
        worksheet_write_string(worksheet12, row, 6, "", formatTopLine)
        worksheet_write_string(worksheet12, row, 7, "", formatTopLine)
        worksheet_write_string(worksheet12, row, 8, "", formatTopLine)
        
        // Set Column Widths
        worksheet_set_column(worksheet12, 3, 0, 3.0, nil)
        worksheet_set_column(worksheet12, 3, 1, 12.0, nil)
        worksheet_set_column(worksheet12, 3, 2, 22.0, nil)
        worksheet_set_column(worksheet12, 3, 3, 8.0, nil)
        worksheet_set_column(worksheet12, 3, 4, 8.0, nil)
        worksheet_set_column(worksheet12, 3, 5, 8.0, nil)
        worksheet_set_column(worksheet12, 3, 6, 8.0, nil)
        worksheet_set_column(worksheet12, 3, 7, 8.0, nil)
        worksheet_set_column(worksheet12, 3, 7, 8.0, nil)
        
        
        
        
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // CV ET Tuning
        // Add a worksheet with a user defined sheet name.
        let worksheet13 = workbook_add_worksheet(workbook, "CV ET")
        worksheet_set_portrait(worksheet13)
        worksheet_set_paper(worksheet13, 3)
        worksheet_set_margins(worksheet13, 0.75, 0.5, 0.5, 0.5)
        // worksheet_fit_to_pages(worksheet12, 1, 1)
        
        worksheet_write_string(worksheet13, 0, 0, controller.config.controllerName.uppercased() + " CV ET Tuning", formatTitle)
        
        row = UInt32(rowOffset - 1)
        
        worksheet_write_string(worksheet13, row, 0, "", formatHeaderUpper)
        worksheet_write_string(worksheet13, row, 1, "", formatHeaderUpper)
        worksheet_write_string(worksheet13, row, 2, "", formatHeaderUpper)
        worksheet_write_string(worksheet13, row, 3, "              ET Rank", formatHeaderLeftTop)
        worksheet_write_string(worksheet13, row, 4, "", formatHeaderRightTop)
        worksheet_write_string(worksheet13, row, 5, "Rank", formatHeaderUpper)
        worksheet_write_string(worksheet13, row, 6, "               ET ECE", formatHeaderLeftTop)
        worksheet_write_string(worksheet13, row, 7, "", formatHeaderRightTop)
        worksheet_write_string(worksheet13, row, 8, "ET", formatHeaderUpper)
        worksheet_write_string(worksheet13, row, 9, "ET Rank", formatHeaderUpper)
        row += 1
        
        worksheet_write_string(worksheet13, row, 0, "No", formatHeaderLower)
        worksheet_write_string(worksheet13, row, 1, "Tag", formatHeaderLower)
        worksheet_write_string(worksheet13, row, 2, "Description", formatHeaderLower)
        worksheet_write_string(worksheet13, row, 3, "Lower", formatHeader)
        worksheet_write_string(worksheet13, row, 4, "Upper", formatHeader)
        worksheet_write_string(worksheet13, row, 5, "Type", formatHeaderLower)
        worksheet_write_string(worksheet13, row, 6, "Lower", formatHeader)
        worksheet_write_string(worksheet13, row, 7, "Upper", formatHeader)
        worksheet_write_string(worksheet13, row, 8, "Range", formatHeaderLower)
        worksheet_write_string(worksheet13, row, 9, "Type", formatHeaderLower)
        row += 1
        
        
        for cv in cvs {
            if cv.etcswc.intValue > 0 {
                worksheet_write_number(worksheet13, row, 0, Double(cv.index + 1), formatMiddleRowCenter)
                worksheet_write_string(worksheet13, row, 1, cv.name, formatMiddleRow)
                worksheet_write_string(worksheet13, row, 2, cv.shortDescription, formatMiddleRow)
                worksheet_write_number(worksheet13, row, 3, cv.etcrl.doubleValue, formatMiddleRow)
                worksheet_write_number(worksheet13, row, 4, cv.etcru.doubleValue, formatMiddleRowDouble)
                var lowSolnType = "L"
                if cv.etclpql.intValue > 0 {
                    lowSolnType = "Q"
                }
                var highSolnType = "L"
                if cv.etclpqu.intValue > 0 {
                    highSolnType = "Q"
                }
                
                worksheet_write_string(worksheet13, row, 5, lowSolnType + highSolnType, formatMiddleRowCenter)
                worksheet_write_number(worksheet13, row, 6, cv.etcecel.doubleValue, formatMiddleRowDouble)
                worksheet_write_number(worksheet13, row, 7, cv.etceceu.doubleValue, formatMiddleRowDouble)
                worksheet_write_number(worksheet13, row, 8, cv.etcrng.doubleValue, formatMiddleRowDouble)
                var etType = "Off"
                if cv.etcswc.intValue == 1 {
                    etType = "RTO"
                } else {
                    etType = "IRV"
                }
                worksheet_write_string(worksheet13, row, 9, etType, formatMiddleRowCenter)
                row += 1
            }
        }
        
        // Bottom Line
        worksheet_write_string(worksheet13, row, 0, "", formatTopLine)
        worksheet_write_string(worksheet13, row, 1, "", formatTopLine)
        worksheet_write_string(worksheet13, row, 2, "", formatTopLine)
        worksheet_write_string(worksheet13, row, 3, "", formatTopLine)
        worksheet_write_string(worksheet13, row, 4, "", formatTopLine)
        worksheet_write_string(worksheet13, row, 5, "", formatTopLine)
        worksheet_write_string(worksheet13, row, 6, "", formatTopLine)
        worksheet_write_string(worksheet13, row, 7, "", formatTopLine)
        worksheet_write_string(worksheet13, row, 8, "", formatTopLine)
        worksheet_write_string(worksheet13, row, 9, "", formatTopLine)
        
        // Set Column Widths
        worksheet_set_column(worksheet13, 4, 0, 3.0, nil)
        worksheet_set_column(worksheet13, 4, 1, 12.0, nil)
        worksheet_set_column(worksheet13, 4, 2, 22.0, nil)
        worksheet_set_column(worksheet13, 4, 3, 8.0, nil)
        worksheet_set_column(worksheet13, 4, 4, 8.0, nil)
        worksheet_set_column(worksheet13, 4, 5, 8.0, nil)
        worksheet_set_column(worksheet13, 4, 6, 8.0, nil)
        worksheet_set_column(worksheet13, 4, 7, 8.0, nil)
        worksheet_set_column(worksheet13, 4, 8, 8.0, nil)
        worksheet_set_column(worksheet13, 4, 9, 8.0, nil)
        
        
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // MVs
        // Add a worksheet with a user defined sheet name.
        let worksheet14 = workbook_add_worksheet(workbook, "MVs")
        worksheet_set_landscape(worksheet14)
        worksheet_set_paper(worksheet14, 2)
        worksheet_set_margins(worksheet14, 0.75, 0.5, 0.5, 0.5)
        // worksheet_fit_to_pages(worksheet2, 1, 1)
        
        // Mvs
        row = 0
        worksheet_write_string(worksheet14, row, 0, "MVs", formatTitle)
        row += 1
        
        worksheet_write_string(worksheet14, row, 0, "No", formatHeader)
        worksheet_write_string(worksheet14, row, 1, "Tag", formatHeader)
        worksheet_write_string(worksheet14, row, 2, "Description", formatHeader)
        worksheet_write_string(worksheet14, row, 3, "LP", formatHeader)
        worksheet_write_string(worksheet14, row, 4, "Notes", formatHeader)
        
        format = formatMiddleRow
        row += 1
        
        for mv in mvs {
            worksheet_write_number(worksheet14, row, 0, Double(mv.index + 1), formatMiddleRowCenter)
            worksheet_write_string(worksheet14, row, 1, mv.name, format)
            worksheet_write_string(worksheet14, row, 2, mv.shortDescription, format)
            var lpDirection = "Move"
            if mv.lpcrit.intValue == 0 {
                if mv.cst.doubleValue > 0 {
                    lpDirection = "Min"
                } else {
                    lpDirection = "Max"
                }
            }
            worksheet_write_string(worksheet14, row, 3, lpDirection, format)
            worksheet_write_string(worksheet14, row, 4, "", format)
            row += 1
        }
        // Bottom Line
        worksheet_write_string(worksheet14, row, 0, "", formatTopLine)
        worksheet_write_string(worksheet14, row, 1, "", formatTopLine)
        worksheet_write_string(worksheet14, row, 2, "", formatTopLine)
        worksheet_write_string(worksheet14, row, 3, "", formatTopLine)
        worksheet_write_string(worksheet14, row, 4, "", formatTopLine)
        
        // Set Column Widths
        worksheet_set_column(worksheet14, 5, 0, 3.0, nil)
        worksheet_set_column(worksheet14, 5, 1, 12.0, nil)
        worksheet_set_column(worksheet14, 5, 2, 22.0, nil)
        worksheet_set_column(worksheet14, 5, 3, 5.0, nil)
        worksheet_set_column(worksheet14, 5, 4, 50.0, nil)
        
        
        
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // FFs
        // Add a worksheet with a user defined sheet name.
        let worksheet15 = workbook_add_worksheet(workbook, "FFs")
        worksheet_set_portrait(worksheet15)
        worksheet_set_paper(worksheet14, 2)
        worksheet_set_margins(worksheet14, 0.75, 0.5, 0.5, 0.5)
        // worksheet_fit_to_pages(worksheet2, 1, 1)
        
        
        row = 0
        worksheet_write_string(worksheet15, 0, 0, controller.config.controllerName.uppercased() + " FFs", formatTitle)
        
        row += 1
        
        worksheet_write_string(worksheet15, row, 0, "No", formatHeader)
        worksheet_write_string(worksheet15, row, 1, "Tag", formatHeader)
        worksheet_write_string(worksheet15, row, 2, "Description", formatHeader)
        worksheet_write_string(worksheet15, row, 3, "Notes", formatHeader)
        row += 1
        
        
        for ff in ffs {
            worksheet_write_number(worksheet15, row, 0, Double(ff.index + 1), formatMiddleRowCenter)
            worksheet_write_string(worksheet15, row, 1, ff.name, formatMiddleRow)
            worksheet_write_string(worksheet15, row, 2, ff.shortDescription, formatMiddleRow)
            worksheet_write_string(worksheet15, row, 3, "", format)
            row += 1
        }
        
        // Bottom Line
        worksheet_write_string(worksheet15, row, 0, "", formatTopLine)
        worksheet_write_string(worksheet15, row, 1, "", formatTopLine)
        worksheet_write_string(worksheet15, row, 2, "", formatTopLine)
        worksheet_write_string(worksheet15, row, 3, "", formatTopLine)
        
        // Set Column Widths
        worksheet_set_column(worksheet15, 5, 0, 3.0, nil)
        worksheet_set_column(worksheet15, 5, 1, 12.0, nil)
        worksheet_set_column(worksheet15, 5, 2, 22.0, nil)
        worksheet_set_column(worksheet15, 5, 3, 55.0, nil)
        
        
        
        
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        //Cvs
        // Add a worksheet with a user defined sheet name.
        let worksheet16 = workbook_add_worksheet(workbook, "CVs")
        worksheet_set_portrait(worksheet16)
        worksheet_set_paper(worksheet16, 2)
        worksheet_set_margins(worksheet16, 0.75, 0.5, 0.5, 0.5)
        // worksheet_fit_to_pages(worksheet2, 1, 1)
        
        row = 0
        // Cvs
        // row += 1
        worksheet_write_string(worksheet16, row, 0, "CVs", formatTitle)
        row += 1
        
        worksheet_write_string(worksheet16, row, 0, "No", formatHeader)
        worksheet_write_string(worksheet16, row, 1, "Tag", formatHeader)
        worksheet_write_string(worksheet16, row, 2, "Description", formatHeader)
        worksheet_write_string(worksheet16, row, 3, "Notes", formatHeader)
        row += 1
        
        
        for cv in cvs {
            worksheet_write_number(worksheet16, row, 0, Double(cv.index + 1), formatMiddleRowCenter)
            worksheet_write_string(worksheet16, row, 1, cv.name, formatMiddleRow)
            worksheet_write_string(worksheet16, row, 2, cv.shortDescription, formatMiddleRow)
            worksheet_write_string(worksheet16, row, 3, "", format)
            row += 1
        }
        
        // Bottom Line
        worksheet_write_string(worksheet16, row, 0, "", formatTopLine)
        worksheet_write_string(worksheet16, row, 1, "", formatTopLine)
        worksheet_write_string(worksheet16, row, 2, "", formatTopLine)
        worksheet_write_string(worksheet16, row, 3, "", formatTopLine)
        
        // Set Column Widths
        worksheet_set_column(worksheet16, 5, 0, 3.0, nil)
        worksheet_set_column(worksheet16, 5, 1, 12.0, nil)
        worksheet_set_column(worksheet16, 5, 2, 22.0, nil)
        worksheet_set_column(worksheet16, 5, 3, 55.0, nil)
        
        ////////////////////////////////////////////
        // CV Transforms
        // Add a worksheet with a user defined sheet name.
        print()
        print("Excel CV Trans")
        let worksheet17 = workbook_add_worksheet(workbook, "CVTrans")
        worksheet_set_portrait(worksheet17)
        worksheet_set_paper(worksheet17, 3)
        worksheet_set_margins(worksheet17, 0.75, 0.5, 0.5, 0.5)
        // worksheet_fit_to_pages(worksheet7, 1, 1)
        
        worksheet_write_string(worksheet17, 0, 0, controller.config.controllerName.uppercased() + " CV Transforms", formatTitle)
        
        row = UInt32(rowOffset - 1)
        
        worksheet_write_string(worksheet17, row, 0, "No", formatHeaderLower)
        worksheet_write_string(worksheet17, row, 1, "Tag", formatHeaderLower)
        worksheet_write_string(worksheet17, row, 2, "Description", formatHeaderLower)
        worksheet_write_string(worksheet17, row, 3, "Transform", formatHeader)
        
        row += 1
        
        for cv in cvs {
            print("\(cv.name)  \(cv.xform.value)")
            let xForm = XForm(cv.xform.value) // get xform value fromn config
            // xForm.parse(cv.xform.value)
            if xForm.type != .none {
                worksheet_write_number(worksheet17, row, 0, Double(cv.index + 1), formatMiddleRowCenter)
                worksheet_write_string(worksheet17, row, 1, cv.name, formatMiddleRow)
                worksheet_write_string(worksheet17, row, 2, cv.shortDescription, formatMiddleRow)
                worksheet_write_string(worksheet17, row, 3, xForm.eqText, formatMiddleRow)
                row += 1
            }
            /*
             if cv.xform.value != "" {
             worksheet_write_number(worksheet17, row, 0, Double(cv.index + 1), formatMiddleRowCenter)
             worksheet_write_string(worksheet17, row, 1, cv.name, formatMiddleRow)
             worksheet_write_string(worksheet17, row, 2, cv.shortDescription, formatMiddleRow)
             if xForm.type == .pwl {
             var eqText = "pwl:"
             for (i, point) in xForm.xFormPoints.enumerated() {
             eqText += "\nx\(i): \(point.x)          y\(i): \(point.y)"
             }
             } else {
             worksheet_write_string(worksheet17, row, 3, xForm.eqText, formatMiddleRow)
             }
             row += 1
             }
             */
        }
        // Bottom Line
        worksheet_write_string(worksheet17, row, 0, "", formatTopLine)
        worksheet_write_string(worksheet17, row, 1, "", formatTopLine)
        worksheet_write_string(worksheet17, row, 2, "", formatTopLine)
        worksheet_write_string(worksheet17, row, 3, "", formatTopLine)
        
        // Set Column Widths
        worksheet_set_column(worksheet17, 4, 0, 3.0, nil)
        worksheet_set_column(worksheet17, 4, 1, 12.0, nil)
        worksheet_set_column(worksheet17, 4, 2, 22.0, nil)
        worksheet_set_column(worksheet17, 4, 3, 40, nil)
        print("Done cvtrans")
        
        
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // MV Transforms
        // Add a worksheet with a user defined sheet name.
        let worksheet18 = workbook_add_worksheet(workbook, "MVTrans")
        worksheet_set_portrait(worksheet18)
        worksheet_set_paper(worksheet18, 3)
        worksheet_set_margins(worksheet18, 0.75, 0.5, 0.5, 0.5)
        // worksheet_fit_to_pages(worksheet7, 1, 1)
        
        worksheet_write_string(worksheet18, 0, 0, controller.config.controllerName.uppercased() + " MV Transforms", formatTitle)
        
        row = UInt32(rowOffset - 1)
        
        worksheet_write_string(worksheet18, row, 0, "No", formatHeaderLower)
        worksheet_write_string(worksheet18, row, 1, "Tag", formatHeaderLower)
        worksheet_write_string(worksheet18, row, 2, "Description", formatHeaderLower)
        worksheet_write_string(worksheet18, row, 3, "Transform", formatHeader)
        
        row += 1
        
        for mv in mvs {
            let xForm = XForm(mv.xform.value)
            // xForm.parse(mv.xform.value)
            if xForm.type != .none {
                worksheet_write_number(worksheet18, row, 0, Double(mv.index + 1), formatMiddleRowCenter)
                worksheet_write_string(worksheet18, row, 1, mv.name, formatMiddleRow)
                worksheet_write_string(worksheet18, row, 2, mv.shortDescription, formatMiddleRow)
                worksheet_write_string(worksheet18, row, 3, xForm.eqText, formatMiddleRow)
                row += 1
            }
            /*
            if mv.xform.value != "" {
                worksheet_write_number(worksheet18, row, 0, Double(mv.index + 1), formatMiddleRowCenter)
                worksheet_write_string(worksheet18, row, 1, mv.name, formatMiddleRow)
                worksheet_write_string(worksheet18, row, 2, mv.shortDescription, formatMiddleRow)
                if xForm.type == .pwl {
                    var eqText = "pwl:"
                    for (i, point) in xForm.xFormPoints.enumerated() {
                        eqText += "\nx\(i): \(point.x)          y\(i): \(point.y)"
                    }
                } else {
                    worksheet_write_string(worksheet18, row, 3, xForm.eqText, formatMiddleRow)
                }
                row += 1
            }
            */
        }
        // Bottom Line
        worksheet_write_string(worksheet18, row, 0, "", formatTopLine)
        worksheet_write_string(worksheet18, row, 1, "", formatTopLine)
        worksheet_write_string(worksheet18, row, 2, "", formatTopLine)
        worksheet_write_string(worksheet18, row, 3, "", formatTopLine)
        
        // Set Column Widths
        worksheet_set_column(worksheet18, 4, 0, 3.0, nil)
        worksheet_set_column(worksheet18, 4, 1, 12.0, nil)
        worksheet_set_column(worksheet18, 4, 2, 22.0, nil)
        worksheet_set_column(worksheet18, 4, 3, 40, nil)
        
        
        
        
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // Gmults
        // Add a worksheet with a user defined sheet name.
        let worksheet19 = workbook_add_worksheet(workbook, "Gmults")
        worksheet_set_portrait(worksheet19)
        worksheet_set_paper(worksheet19, 3)
        worksheet_set_margins(worksheet19, 0.75, 0.5, 0.5, 0.5)
        // worksheet_fit_to_pages(worksheet7, 1, 1)
        
        worksheet_write_string(worksheet19, 0, 0, controller.config.controllerName.uppercased() + " GMults", formatTitle)
        
        row = UInt32(rowOffset - 1)
        
        worksheet_write_string(worksheet19, row, 0, "No", formatHeader)
        worksheet_write_string(worksheet19, row, 1, "Ind", formatHeader)
        worksheet_write_string(worksheet19, row, 2, "No", formatHeader)
        worksheet_write_string(worksheet19, row, 3, "Dep", formatHeader)
        worksheet_write_string(worksheet19, row, 4, "Gmult", formatHeader)
        
        row += 1
        
        print("Gmults")
        // let inds = dmcController.inds
        for gmult in gmults {
            print(gmult.indIndex, gmult.depIndex, gmult.value)
            if gmult.value != 1.0 {
                let ind = inds[gmult.indIndex]
                let cv = cvs[gmult.depIndex]
                worksheet_write_number(worksheet19, row, 0, Double(ind.index + 1), formatMiddleRowCenter)
                worksheet_write_string(worksheet19, row, 1, ind.name, formatMiddleRow)
                worksheet_write_number(worksheet19, row, 2, Double(cv.index + 1), formatMiddleRowCenter)
                worksheet_write_string(worksheet19, row, 3, cv.name, formatMiddleRow)
                worksheet_write_number(worksheet19, row, 4, Double(gmult.value), formatMiddleRowDouble)
                row += 1
            }
        }
        // Bottom Line
        worksheet_write_string(worksheet19, row, 0, "", formatTopLine)
        worksheet_write_string(worksheet19, row, 1, "", formatTopLine)
        worksheet_write_string(worksheet19, row, 2, "", formatTopLine)
        worksheet_write_string(worksheet19, row, 3, "", formatTopLine)
        worksheet_write_string(worksheet19, row, 4, "", formatTopLine)
        
        // Set Column Widths
        worksheet_set_column(worksheet19, 4, 0, 3.0, nil)
        worksheet_set_column(worksheet19, 4, 1, 12.0, nil)
        worksheet_set_column(worksheet19, 4, 2, 3.0, nil)
        worksheet_set_column(worksheet19, 4, 3, 12.0, nil)
        worksheet_set_column(worksheet19, 4, 4, 13, nil)
        
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // Calcs
        // Add a worksheet with a user defined sheet name.
        let worksheet20 = workbook_add_worksheet(workbook, "Calcs")
        worksheet_set_portrait(worksheet20)
        worksheet_set_paper(worksheet20, 3)
        worksheet_set_margins(worksheet20, 0.75, 0.5, 0.5, 0.5)
        // worksheet_fit_to_pages(worksheet7, 1, 1)
        
        worksheet_write_string(worksheet20, 0, 0, controller.config.controllerName.uppercased() + " Calcs", formatTitle)
        
        row = UInt32(rowOffset - 1)
        
        worksheet_write_string(worksheet20, row, 0, "No", formatHeader)
        worksheet_write_string(worksheet20, row, 1, "Calc", formatHeader)
        // worksheet_write_string(worksheet10, row, 2, "Calc", formatHeader)
        // worksheet_write_string(worksheet20, row, 3, "Dep", formatHeader)
        // worksheet_write_string(worksheet20, row, 4, "Gmult", formatHeader)
        
        row += 1
        
        print("Calcs")
        
        for calc in calcSection.params {
            print(calc.id, calc.name)
            if calc.name.left(4) == "COMM" {
                worksheet_write_number(worksheet20, row, 0, Double(calc.index + 1), formatMiddleRowCenterGreen)
                worksheet_write_string(worksheet20, row, 1, calc.value, formatMiddleRowGreen)
            } else {
                worksheet_write_number(worksheet20, row, 0, Double(calc.index + 1), formatMiddleRowCenter)
                worksheet_write_string(worksheet20, row, 1, calc.value, formatMiddleRow)
            }
            // worksheet_write_string(worksheet20, row, 2, calc.value, formatMiddleRowCenter)
            //worksheet_write_string(worksheet120 row, 3, cv.name, formatMiddleRow)
            // worksheet_write_number(worksheet20, row, 4, Double(gmult.gmult), formatMiddleRowDouble)
            row += 1
        }
        // Bottom Line
        worksheet_write_string(worksheet20, row, 0, "", formatTopLine)
        worksheet_write_string(worksheet20, row, 1, "", formatTopLine)
        // worksheet_write_string(worksheet19, row, 2, "", formatTopLine)
        // worksheet_write_string(worksheet19, row, 3, "", formatTopLine)
        // worksheet_write_string(worksheet19, row, 4, "", formatTopLine)
        
        // Set Column Widths
        worksheet_set_column(worksheet20, 4, 0, 3.0, nil)
        worksheet_set_column(worksheet20, 4, 1, 140.0, nil)
        worksheet_set_column(worksheet20, 4, 2, 12.0, nil)
        worksheet_set_column(worksheet20, 4, 3, 12.0, nil)
        worksheet_set_column(worksheet20, 4, 4, 13, nil)
        
        
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // Calc Params
        // Add a worksheet with a user defined sheet name.
        let worksheet21 = workbook_add_worksheet(workbook, "Params")
        worksheet_set_portrait(worksheet21)
        worksheet_set_paper(worksheet21, 3)
        worksheet_set_margins(worksheet21, 0.75, 0.5, 0.5, 0.5)
        // worksheet_fit_to_pages(worksheet7, 1, 1)
        
        worksheet_write_string(worksheet20, 0, 0, controller.config.controllerName.uppercased() + " Calcs", formatTitle)
        
        row = UInt32(rowOffset - 1)
        
        worksheet_write_string(worksheet21, row, 0, "No", formatHeader)
        worksheet_write_string(worksheet21, row, 1, "Param", formatHeader)
        worksheet_write_string(worksheet21, row, 2, "Description", formatHeader)
        // worksheet_write_string(worksheet21, row, 3, "Dep", formatHeader)
        // worksheet_write_string(worksheet21, row, 4, "Gmult", formatHeader)
        
        row += 1
        
        print("Calc Params")
        
        var i = 1
        for param in calcParams {
            print(i, param.name)
            worksheet_write_number(worksheet21, row, 0, Double(i), formatMiddleRowCenter)
            worksheet_write_string(worksheet21, row, 1, param.name, formatMiddleRow)
            worksheet_write_string(worksheet21, row, 2, "", formatMiddleRowCenter)
            //worksheet_write_string(worksheet21 row, 3, cv.name, formatMiddleRow)
            // worksheet_write_number(worksheet21, row, 4, Double(gmult.gmult), formatMiddleRowDouble)
            i += 1
            row += 1
        }
        // Bottom Line
        worksheet_write_string(worksheet21, row, 0, "", formatTopLine)
        worksheet_write_string(worksheet21, row, 1, "", formatTopLine)
        worksheet_write_string(worksheet21, row, 2, "", formatTopLine)
        // worksheet_write_string(worksheet21, row, 3, "", formatTopLine)
        // worksheet_write_string(worksheet21, row, 4, "", formatTopLine)
        
        // Set Column Widths
        worksheet_set_column(worksheet21, 4, 0, 3.0, nil)
        worksheet_set_column(worksheet21, 4, 1, 15.0, nil)
        worksheet_set_column(worksheet21, 4, 2, 50.0, nil)
        worksheet_set_column(worksheet21, 4, 3, 12.0, nil)
        worksheet_set_column(worksheet21, 4, 4, 13, nil)
        
        
        
        
        
        // Close the workbook, save the file and free any memory
        workbook_close(workbook)
        
        
        
    }
    
    
}

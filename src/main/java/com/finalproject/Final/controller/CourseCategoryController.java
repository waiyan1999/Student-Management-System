package com.finalproject.Final.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.finalproject.Final.dto.CourseCategoryDTO;
import com.finalproject.Final.model.CourseCategoryBean;
import com.finalproject.Final.service.CourseCategoryService;



/**
 * Course Category CRUD
 * 
 * @author WYTM
 *
 */

@Controller
@RequestMapping("/course-category")
public class CourseCategoryController {
	
	@Autowired
	CourseCategoryService courseCategoryService;
	
	@GetMapping("/list")
	public String showAllCourseCategory(Model m) {
		List<CourseCategoryBean> courseCategoryList = courseCategoryService.getAllCourseCategory();
		m.addAttribute("courseCategoryList",courseCategoryList);
		m.addAttribute("courseCategory", new CourseCategoryDTO());
		return "admin/course-category";
	}
	
	@PostMapping("/create")
	public String createCourseCategory(@ModelAttribute("courseCategory") CourseCategoryDTO courseCatDTO) {
		courseCategoryService.createCourseCategory(courseCatDTO);
		return "redirect:/course-category/list";
	}
	
	@GetMapping("/list/{courseCategoryId}")
	public String showCourseCategoryById(@PathVariable("courseCategoryId") int courseCatId,RedirectAttributes ra) {
		CourseCategoryBean courseCategory = courseCategoryService.getCourseCategoryById(courseCatId);
		ra.addFlashAttribute("courseCategory",courseCategory);
		return "redirect:/list";
	}
	
	/*
	 * @GetMapping("/update/{courseCategoryId}") public String
	 * updateCourseCategory(@PathVariable("courseCategoryId") int courseCatId ) {
	 * courseCategoryService.updateCoureCategory(courseCatId); return
	 * "redirect:/list"; }
	 */
	
	@PostMapping("/update/{courseCategoryId}")
    public String updateCourseCategory(@PathVariable("courseCategoryId") int courseCatId,
                                       @RequestParam("name") String name,
                                       RedirectAttributes ra) {
        courseCategoryService.updateCoureCategory(courseCatId, name);
        ra.addFlashAttribute("flashMessage", "Category updated successfully!");
        return "redirect:/course-category/list";
    }
	
	@GetMapping("/delete/{courseCategoryId}")
	public String deleteCourseCategory(@PathVariable("courseCategoryId") int courseCatId) {
		courseCategoryService.deleteCourseCategory(courseCatId);
		return "redirect:/course-category/list";
	}
	
	
	
	
}

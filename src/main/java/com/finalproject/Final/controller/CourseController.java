package com.finalproject.Final.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/courses")
public class CourseController {
	
	@GetMapping("/show")
	  public String showCoursePage() {
		  
		  
		  return "courses";
		  
	  }

}

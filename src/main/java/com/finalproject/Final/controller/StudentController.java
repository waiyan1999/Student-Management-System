package com.finalproject.Final.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import com.finalproject.Final.model.CourseBean;
import com.finalproject.Final.model.EnrollmentBean;
import com.finalproject.Final.model.UserBean;
import com.finalproject.Final.service.EnrollmentService;
import com.finalproject.Final.service.UserService;
import com.finalproject.Final.util.UserCodeUtil;

import jakarta.servlet.http.HttpSession;

@Controller
@RequestMapping("/student")
public class StudentController {
	
	@Autowired
	private UserService userService;
	
	@Autowired
	private EnrollmentService enrollmentService;
	
	
	@GetMapping("/portal")
	public String showStudentHome(Model model, HttpSession session) {

//	    UserBean student = userService.findById(5); // temporary hardcoded
		
		 UserBean student = (UserBean)session.getAttribute("loginUser");

	    List<CourseBean> courses =  enrollmentService.getEnrolledCourses(student.getId());
//	           

	    model.addAttribute("student", student);
	    model.addAttribute("studentCode", 
	    		UserCodeUtil.formatUserCode(student.getRoleId(), student.getId()));
	           
	    model.addAttribute("courses", courses);
	    model.addAttribute("enrolledCoursesCount", courses.size());

	    return "student/student-home";
	}
	
	

}

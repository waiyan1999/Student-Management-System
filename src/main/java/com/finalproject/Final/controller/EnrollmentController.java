package com.finalproject.Final.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.finalproject.Final.dto.EnrollmentDTO;
import com.finalproject.Final.model.CourseBean;
import com.finalproject.Final.model.EnrollmentBean;
import com.finalproject.Final.model.CourseBean;
import com.finalproject.Final.model.ScheduleBean;
import com.finalproject.Final.model.UserBean;
import com.finalproject.Final.service.CourseService;
import com.finalproject.Final.service.EnrollmentService;
import com.finalproject.Final.service.ScheduleService;
import com.finalproject.Final.service.UserService;

import jakarta.servlet.http.HttpSession;

@Controller
@RequestMapping("/enrollment")
public class EnrollmentController {
	
	@Autowired
	private CourseService courseService;

    @Autowired
    private EnrollmentService enrollmentService;
    
    @Autowired
    private ScheduleService scheduleService;
    
    @Autowired
    private UserService userService;
    
    @GetMapping("/show")
    public String showEnrollPage(@RequestParam int courseId,
                                 HttpSession session,
                                 Model model) {

    	//use this when login is complete
        UserBean student = (UserBean)session.getAttribute("loginUser");
    	
    	//temporary
    	//to replace with above code
    	//1 is Aung Aung
//    	UserBean student = userService.findById(5);

    	
        CourseBean course = courseService.getById(courseId);

        List<ScheduleBean> schedules =
                scheduleService.getByCourseId(courseId);

        model.addAttribute("student", student);
        model.addAttribute("course", course);
        model.addAttribute("schedules", schedules);

        return "enroll-confirm";
    }

    //create enrollment when user clicks Enroll
    @PostMapping("/create")
    public String createEnrollment(EnrollmentDTO dto, RedirectAttributes ra) {

        try {
            int enrollmentId = enrollmentService.createEnrollment(dto);
            return "redirect:/payment/page/" + enrollmentId;

        } catch (RuntimeException e) {

            ra.addFlashAttribute("errorMessage", e.getMessage());
            return "redirect:/courses/" + dto.getCourseId();
        }
    }
    
   

    
    

    // view user enrollments
    @GetMapping("/my")
    public String myEnrollments(@RequestParam int userId, Model model) {
        model.addAttribute("enrollments",
                enrollmentService.getByUser(userId));
        return "my-enrollments";
    }
}

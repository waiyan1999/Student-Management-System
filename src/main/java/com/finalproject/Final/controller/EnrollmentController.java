package com.finalproject.Final.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.finalproject.Final.service.EnrollmentService;

@Controller
@RequestMapping("/enrollment")
public class EnrollmentController {

    @Autowired
    private EnrollmentService enrollmentService;

    //create enrollment when user clicks Enroll
    @PostMapping("/create")
    public String createEnrollment(@RequestParam int userId,
                                   @RequestParam int courseId,
                                   RedirectAttributes redirectAttributes) {

        int enrollmentId = enrollmentService.createEnrollment(userId, courseId);

        // redirect to payment page
        //edit
        return "redirect:/payment/page/" + enrollmentId;
    }

    // view user enrollments
    @GetMapping("/my")
    public String myEnrollments(@RequestParam int userId, Model model) {
        model.addAttribute("enrollments",
                enrollmentService.getByUser(userId));
        return "my-enrollments";
    }
}

package com.finalproject.Final.controller;


import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;


import com.finalproject.Final.dto.PaymentDTO;
import com.finalproject.Final.model.CourseBean;
import com.finalproject.Final.model.EnrollmentBean;
import com.finalproject.Final.service.CourseService;
import com.finalproject.Final.service.EnrollmentService;
import com.finalproject.Final.service.PaymentService;

@Controller
@RequestMapping("/payment")
public class PaymentController {

    @Autowired
    private PaymentService paymentService;

    @Autowired
    private EnrollmentService enrollmentService;

    // show payment page
    @Autowired
    private CourseService courseService;

    @GetMapping("/page/{enrollmentId}")
    public String paymentPage(@PathVariable int enrollmentId, Model model) {

        try {
            EnrollmentBean enrollment = enrollmentService.getById(enrollmentId);
            CourseBean course = courseService.getById(enrollment.getCourseId());

            model.addAttribute("enrollment", enrollment);
            model.addAttribute("course", course);

            return "payment";

        } catch (RuntimeException e) {

            model.addAttribute("errorMessage", e.getMessage());
            return "payment";
        }
    }

    // process payment
//    @PostMapping("/pay")
//    public String pay(PaymentDTO dto) {
//
//        paymentService.processPayment(dto);
//
//        return "redirect:/enrollment/my?userId=" + dto.getUserId();
//    }
    
    @GetMapping("/success/{enrollmentId}")
    public String enrollSuccess(@PathVariable int enrollmentId,
                                Model model) {

        EnrollmentBean enrollment = enrollmentService.getById(enrollmentId);

        CourseBean course =  courseService.getById(enrollment.getCourseId());
               
        model.addAttribute("enrollment", enrollment);
        model.addAttribute("course", course);
        model.addAttribute("paymentStatus", "PAID");

        return "enroll-success";
    }
    
    @PostMapping("/pay")
    public String pay(PaymentDTO dto) {

        paymentService.processPayment(dto);

        return "redirect:/payment/success/" + dto.getEnrollmentId();
    }
}


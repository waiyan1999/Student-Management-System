package com.finalproject.Final.Controller;

import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

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
    @GetMapping("/page/{enrollmentId}")
    public String paymentPage(@PathVariable int enrollmentId, Model model) {

        Map<String, Object> enrollment = enrollmentService.getById(enrollmentId);

        model.addAttribute("enrollment", enrollment);
        return "payment-page";
    }

    // process payment
    @PostMapping("/pay")
    public String processPayment(@RequestParam int enrollmentId,
                                 @RequestParam int userId,
                                 @RequestParam int amount,
                                 @RequestParam String paymentMethod,
                                 @RequestParam String paymentType,
                                 @RequestParam int courseId) {

        paymentService.processPayment(enrollmentId, userId, amount, paymentMethod, paymentType, courseId);

        return "redirect:/enrollment/my?userId=" + userId;
    }
}

package com.finalproject.Final.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.finalproject.Final.repository.UserRepository;
@Controller
public class ForgotPasswordController {

    @Autowired
    private UserRepository uRepo;
    @GetMapping("/forgot-password")
    public String forgotPasswordPage() {
        return "forgot-password"; 
    }

    @PostMapping("/forgot-password")
    public String resetPassword(@RequestParam String email,
                                 @RequestParam String newPassword,
                                 Model m) {

        int result = uRepo.updatePassword(email, newPassword);

        if (result > 0) {
            m.addAttribute("message", "Password updated successfully. Please login.");
        } else {
            m.addAttribute("error", "Email not found");
        }

        return "forgot-password"; 
    }
}
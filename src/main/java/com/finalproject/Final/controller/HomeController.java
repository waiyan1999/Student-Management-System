package com.finalproject.Final.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import com.finalproject.Final.model.UserBean;

import jakarta.servlet.http.HttpSession;

@Controller
public class HomeController {

    @GetMapping("/home")
    public String homePage(HttpSession session, Model m) {

        UserBean user = (UserBean) session.getAttribute("loginUser");
        if (user == null) {
            return "redirect:/login";
        }

        m.addAttribute("user", user);
        return "layout/index"; 
    }
}
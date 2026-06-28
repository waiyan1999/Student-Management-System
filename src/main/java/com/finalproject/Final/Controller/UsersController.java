package com.finalproject.Final.Controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class UsersController {

    @GetMapping("/users")
    public String showUsers() {
        return "users";
    }
}

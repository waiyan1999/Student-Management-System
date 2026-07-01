package com.finalproject.Final.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import com.finalproject.Final.model.SubCategoryBean;
import com.finalproject.Final.repository.SubCategoryRepository;

@Controller
public class IndexController {

    @Autowired
    private SubCategoryRepository subRepo;

    @GetMapping("/")
    public String showHomePage(Model model) {

    	 List<SubCategoryBean> allList = subRepo.getAllSubCategory();

    	    model.addAttribute("allList", allList);


        return "index";
    }

}
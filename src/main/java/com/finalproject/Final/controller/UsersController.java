package com.finalproject.Final.controller;

import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

import javax.imageio.ImageIO;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;

import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;

import com.finalproject.Final.model.UsersBean;
import com.finalproject.Final.repository.UsersRepository;

import jakarta.validation.Valid;



@Controller
@RequestMapping("/student")
public class UsersController {
	
	@Autowired
	private UsersRepository uRepo;
	
	@GetMapping("/register")
	public String registerPage(Model m) {
		 UsersBean user = new UsersBean();
		    user.setGender("Male");   // Default selected
		    m.addAttribute("userObj", user);
	   // m.addAttribute("userObj", new UserBean());
	   // return "success";
	    
	    return "student_register";
	}
	@GetMapping("/registers")
	public String success(Model m) {
		 UsersBean user = uRepo.getLatestStudent();
	    m.addAttribute("userObj", user);
	    
	   // return "success";
	    return "success";
	}
	
	
	
	@PostMapping("/register")
	public String studentRegistrater(@Valid @ModelAttribute("userObj")UsersBean obj,
			BindingResult br,Model m,
			@RequestParam("photo") MultipartFile photo) throws IOException {
		
		//age must be 16 vallidation
		if (obj.getDob() != null &&
		        obj.getDob().isAfter(LocalDate.now().minusYears(16))) {
           br.rejectValue(
		                "dob",
		                "error.dob",
		                "Age must be at least 16 years old"); }
		
		if(br.hasErrors()) {
			return"student_register";
		}
		
		if (photo.isEmpty()) {
	        m.addAttribute("error", "Please select a photo");
	        return "student_register";
	    }
		//photo size 
		 long maxSize = 2 * 1024 * 1024;
	     if (photo.getSize() > maxSize) {
		        m.addAttribute("error",
		                "Photo size must not exceed 2 MB!");
		        return"student_register";
	     }
		        
		         // Content Type Validation
			    String contentType = photo.getContentType();

			    if (contentType == null ||
			            !(contentType.equals("image/jpeg")
			                    || contentType.equals("image/png"))) {

			        m.addAttribute("error", "Invalid image file");
			        return "student_register";
			    }
			    
			    BufferedImage image = ImageIO.read(photo.getInputStream());
		    if (image == null) {
			        m.addAttribute("error",
			                "Invalid image file");
			        return "student_register";
			        }
		    String fileName = photo.getOriginalFilename();

	        String path = "D:/upload/";
//file 
	        File dir = new File(path);
	        if (!dir.exists()) {
	            dir.mkdirs();
	        }
	        //save file
	        photo.transferTo(new File(path + fileName));

	        //save file path
	        obj.setFilePath("/upload/" + fileName);
			    
			   
		    if(uRepo.existsByEmail(obj.getEmail())) {
			    m.addAttribute("emailError",
			            "Email already exists");
			    return "student_register";
			}

	  obj.setRoleId(3); // Student
	    obj.setIsActive(1);
	    obj.setCreatedAt(LocalDateTime.now());
	 
	    uRepo.insertUser(obj);
	    m.addAttribute("userObj", obj);

	   // return "redirect:/login";
		
		
	return "success";
	}
	
	
	@PostMapping("/update")
	public String updateStudent(
	        @Valid @ModelAttribute("userObj") UsersBean userObj,
	        BindingResult br,
	        Model model,
	        @RequestParam("photo") MultipartFile photo) throws IOException {

	    // Age Validation
	    if (userObj.getDob() != null &&
	            userObj.getDob().isAfter(LocalDate.now().minusYears(16))) {

	        br.rejectValue(
	                "dob",
	                "error.dob",
	                "Age must be at least 16 years old.");
	    }

	    if (br.hasErrors()) {
	        return "student_edit";
	    }

	    // Get Existing User
	    UsersBean oldUser = uRepo.getUserById(userObj.getId());

	    if (oldUser == null) {
	        model.addAttribute("error", "User not found.");
	        return "student_edit";
	    }

	    // Email Duplicate Check
	    UsersBean emailUser = uRepo.getUserByEmail(userObj.getEmail());

	    if (emailUser != null &&
	            emailUser.getId() != userObj.getId()) {

	        model.addAttribute(
	                "emailError",
	                "Email already exists.");
          return "student_edit";
	    }

	    // Photo Upload (Optional)
	    if (!photo.isEmpty()) {

	        // Size Validation
	        long maxSize = 5 * 1024 * 1024;

	        if (photo.getSize() > maxSize) {

	            model.addAttribute(
	                    "error",
	                    "Photo size must not exceed 5 MB.");

	            return "student_edit";
	        }

	        // Content Type Validation
	        String contentType = photo.getContentType();

	        if (contentType == null ||
	                !(contentType.equals("image/jpeg")
	                        || contentType.equals("image/png"))) {

	            model.addAttribute(
	                    "error",
	                    "Only JPG and PNG images are allowed.");

	            return "student_edit";
	        }

	        // Check Image
	        BufferedImage image =
	                ImageIO.read(photo.getInputStream());

	        if (image == null) {

	            model.addAttribute(
	                    "error",
	                    "Invalid image.");

	            return "student_edit";
	        }

	        // Upload Folder
	        String uploadPath = "D:/upload/";

	        File dir = new File(uploadPath);

	        if (!dir.exists()) {
	            dir.mkdirs();
	        }

	        // Unique File Name
	       // String fileName =
	             //   UUID.randomUUID() + "_"
	                      //  + photo.getOriginalFilename();

	        // Save File
	    String fileName=photo.getOriginalFilename();//n
	    		photo.transferTo(new File(dir, fileName));

	        userObj.setFilePath("/upload/" + fileName);
	        //System.out.println(userObj.getFilePath());
	    } else {

	        // Keep Old Photo
	        userObj.setFilePath(oldUser.getFilePath());

	    }

	    // Keep Existing Data
	    userObj.setRoleId(oldUser.getRoleId());
	    userObj.setIsActive(oldUser.getIsActive());
	    userObj.setCreatedAt(oldUser.getCreatedAt());

	    // Update User
	    uRepo.updateUser(userObj);
return "success";
	   // return "redirect:/update";
	}
	
	@GetMapping("/update")
	public String update(Model m) {
		 UsersBean user = uRepo.getLatestStudent();
	    m.addAttribute("userObj", user);
	    
	    
	   // return "success";
	    return "student_edit";
	}
}

package com.finalproject.Final.controller;

import java.awt.image.BufferedImage;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;

import javax.imageio.ImageIO;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import com.finalproject.Final.Bean.TeacherBean;
import com.finalproject.Final.repository.TeacherRepository;


//import com.springboot.Repository.UsersRepository;

//import com.springboot.model.UserBeans;
//import com.springboot.model.uploadBean;

import jakarta.validation.Valid;
//import com.springboot.repository.StudentRepository;
//import com.springboot.repository.UserRepository;





@Controller
@RequestMapping("/users")
public class TeacherController {
	@Autowired
	private TeacherRepository  mRepo;
	
	@GetMapping("/forms")
	public ModelAndView showForm() {
		
		return new ModelAndView("teacher/create-teacher","userObj",new TeacherBean());
		
	}
	@PostMapping("/teacherRegister")
	public String teacherRegister(@Valid @ModelAttribute("userObj") TeacherBean obj,   BindingResult result,  MultipartFile file,Model m) throws IllegalStateException, IOException {

	   	      
		   if (file.isEmpty()) {		    	
		        m.addAttribute("fileError", "Please select image");
		        	
		    }
		    if (result.hasErrors() || file.isEmpty()) {
				  return "teacher/create-teacher"; 
			    }
		  //long maxSize=5*1024;
			  long maxSize=2*1024*1024;
		    if (file.getSize() > maxSize) {
			    m.addAttribute("fileError", "File size must be less than 2MB");
			    	return "teacher/create-teacher";
			}
		    
		    String contentType = file.getContentType();
		    System.out.println(contentType);
		    if(contentType == null ||
		       !contentType.startsWith("image/")) {
		        	m.addAttribute("fileError", "Only image files are allowed");
		        		return "teacher/create-teacher";
		    }
		    BufferedImage image = ImageIO.read(file.getInputStream());
		    if (image == null) {
		        m.addAttribute("fileError", "Invalid image file");
		        return "teacher/create-teacher";
		    }

	       String fileName = file.getOriginalFilename();	      			      
	      Path path = Paths.get("uploads/" + fileName);
	      	file.transferTo(path);
	     	    
	      m.addAttribute("fileName", fileName);
	      	obj.setFilePath("uploads/" + fileName);
	    obj.setRoleId(2);      
	    obj.setIsActive(1);  

	    int i= mRepo.insertTeacher(obj);

		if(i!=0) {
  			return "redirect:/users/teacherList";
    }
  		else {
  			m.addAttribute("fail","inser fail");
  				return "redirect:forms";
  			}
		}
	 @Configuration
	 public class WebConfig implements WebMvcConfigurer {	
	    @Override
		    public void addResourceHandlers(ResourceHandlerRegistry registry) {		
		          registry.addResourceHandler("/uploads/**")
		                  .addResourceLocations("file:uploads/");
		       }
		  }
  
	  @GetMapping("/teacherLists")
	  public String showAllTeacher(Model m) {
		  List<TeacherBean> list=mRepo.getAllTeacher();
		  	m.addAttribute("teacherList",list);
		  		return "teacher/teachers-list";
	  		}
	  @GetMapping("/getbyid")
	  	public ModelAndView getById(@RequestParam ("id") Integer id) {
		 TeacherBean obj=mRepo.getByTeacherId(id);
		  //	System.out.println("GET IMAGE = " + obj.getImagepath());
		  		return new ModelAndView("teacher-edit","teacherObj",obj);
	  		}
	  @PostMapping("/update")
	  	public String updateUpload(  @Valid @ModelAttribute("teacherObj") TeacherBean obj,  BindingResult result,	@RequestParam("file") MultipartFile file,Model m) throws IOException {
		  if (result.hasErrors()) {
		        return "teacher/teacher-edit";
		    }

		  TeacherBean oldObj = mRepo.getByTeacherId(obj.getId());

		  if (file != null && !file.isEmpty()) {

		 long maxSize=2*1024*1024;
			 // long maxSize=5*1024;
		  	if (file.getSize() > maxSize) {
			    m.addAttribute("fileError", "File size must be less than 2MB");
			    	return "teacher/teacher-edit";
			 }
		  
		  String contentType = file.getContentType();			 
		    if(contentType == null ||
		    		!contentType.startsWith("image/")) {
		    			m.addAttribute("upObj", obj);
		    				m.addAttribute("fileError", "Only image files are allowed");
		    					return "teacher-edit";
		     }	
		    if (oldObj.getFilePath() != null) {
		        Files.deleteIfExists(Paths.get(oldObj.getFilePath()));
		    }
	      String fileName = file.getOriginalFilename();		  	
	      	Path path = Paths.get("uploads/" + fileName);
	      		file.transferTo(path);
	    
	      m.addAttribute("fileName", fileName);
	      	obj.setFilePath("uploads/" + fileName);

		  } else {
			    // Keep previous photo
			    obj.setFilePath(oldObj.getFilePath());
			}

           int i=mRepo.updateUpload(obj);	  
           	return "redirect:/users/teacherLists";
	  		}
	  }


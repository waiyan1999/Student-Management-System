package com.finalproject.Final.model;

import java.time.LocalDate;
import java.time.LocalDateTime;



import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class UserBean {

    private int id;

    // ROLE 
    // 1 = ADMIN
    // 2 = TEACHER
    // 3 = STUDENT
    private int roleId;

    private String name;
    private String email;
    private String password;

    private String phoneNo;
    private String address;

    private LocalDate dob;
    private String gender;

    private LocalDateTime createdAt;

    private boolean isActive;

    private String filePath;
    
 
   
}
package com.finalproject.Final.model;

import java.time.LocalDate;
import java.time.LocalDateTime;

import org.springframework.format.annotation.DateTimeFormat;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Past;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class UserBean {
	
	private Integer id;

	private Integer roleId;
@NotBlank(message="Name is required")
@Pattern(
	    regexp = "^[A-Z][a-zA-Z ]*$",
	    message = "Name must start with a capital letter"
	)
	private String name;


	@NotBlank(message="Email is required")
	@Email(message = "Invalid email format")
	private String email;
	
	
	@Size(
		    min = 6,
		    message = "Password must be at least 6 characters long."
		)

		@Pattern(
		    regexp = ".*[A-Za-z].*",
		    message = "Password must contain at least one letter."
		)

		@Pattern(
		    regexp = ".*\\d.*",
		    message = "Password must contain at least one number."
		)
	private String password;
	
	
	@NotBlank(message = "Phone number is required")
	@Pattern(
	    regexp = "^09\\d{7,9}$",
	    message = "Invalid phone number"
	)
	private String phoneNumber;
	
	
	@NotBlank(message="Address is required")
	private String address;
	
	
	@NotNull(message="Date of birth is required")
	@Past(message = "Date of birth must be in the past")
	@DateTimeFormat(pattern = "dd-MM-yyyy")
	private LocalDate dob;
	
	
	@NotBlank(message="Gender is required")
	private String gender;
	
	
	private LocalDateTime createdAt;
	private Integer isActive;
	
	
	private String filePath;
}

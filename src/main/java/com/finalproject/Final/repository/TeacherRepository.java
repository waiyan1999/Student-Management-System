package com.finalproject.Final.repository;

import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import com.finalproject.Final.Bean.TeacherBean;



//import jakarta.validation.constraints.NotBlank;
@Repository
public class TeacherRepository {
	  @Autowired
	    private JdbcTemplate jdbc;

	    public int insertTeacher(TeacherBean obj) {

	        int i = 0;

	        String sql = "INSERT INTO user "
	                + "(role_id, name, email, password, phone_no, address, dob, gender, created_at, is_active, file_path) "
	                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW(), ?, ?)";

	        i = jdbc.update(
	                sql,
	                obj.getRoleId(),
	                obj.getName(),
	                obj.getEmail(),
	                obj.getPassword(),
	                obj.getPhoneNo(),
	                obj.getAddress(),
	                obj.getDob(),
	                obj.getGender(),
	                obj.getIsActive(),
	                obj.getFilePath()
	        );

	        return i;
	    }
	    public List<TeacherBean> getAllTeacher() {

	        List<TeacherBean> list = new ArrayList<TeacherBean>();

	        String sql = "SELECT * FROM user WHERE role_id = 2";

	        list = jdbc.query(
	                sql,
	                (rs, rowNum) ->
	                    new TeacherBean(
	                            rs.getInt("id"),
	                            rs.getInt("role_id"),
	                            rs.getString("name"),
	                            rs.getString("email"),
	                            rs.getString("password"),
	                            rs.getString("phone_no"),
	                            rs.getString("address"),
	                            rs.getString("dob"),
	                            rs.getString("gender"),
	                            rs.getTimestamp("created_at"),
	                            rs.getInt("is_active"),
	                            rs.getString("file_path"))
	        );

	        return list;
	    }
	    public TeacherBean getByTeacherId(int id) {
			TeacherBean teaObj=null;
			String sql="SELECT * FROM user where id=?";
			
		teaObj=jdbc.queryForObject(sql, 
					(rs,rowCount)-> new TeacherBean(
							 rs.getInt("id"),
	                            rs.getInt("role_id"),
	                            rs.getString("name"),
	                            rs.getString("email"),
	                            rs.getString("password"),
	                            rs.getString("phone_no"),
	                            rs.getString("address"),
	                            rs.getString("dob"),
	                            rs.getString("gender"),
	                            rs.getTimestamp("created_at"),
	                            rs.getInt("is_active"),
	                            rs.getString("file_path")
							),
					
							id
					
					
					);
			
			
		return teaObj;
			
		}
		public int updateUpload(TeacherBean obj) {
			int i=0;
			
			 String sql="UPDATE user SET  name=?, email=?, password=?, phone_no=?, address=?, dob=?, gender=?, is_active=?, file_path=? WHERE id=?";
			 i=jdbc.update(sql,obj.getName(),obj.getEmail(),obj.getPassword(),obj.getPhoneNo(),obj.getAddress(),obj.getDob(),obj.getGender(),obj.getIsActive(),obj.getFilePath(),  obj.getId());
			 
			return i;
		}
	}
 



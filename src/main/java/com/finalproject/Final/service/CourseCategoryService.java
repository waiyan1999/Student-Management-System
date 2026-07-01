package com.finalproject.Final.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.finalproject.Final.dto.CourseCategoryDTO;
import com.finalproject.Final.model.CourseCategoryBean;
import com.finalproject.Final.repository.CourseCategoryRepository;

/**
 * Course Category CRUD
 * 
 * @author WYTM
 *
 */

@Service
public class CourseCategoryService {

	@Autowired
	CourseCategoryRepository courseCategoryReop;

	public boolean createCourseCategory(CourseCategoryDTO courseCategory) {

		int result = 0;

		result = courseCategoryReop.createdCourseCategory(courseCategory);

		if (result > 0) {
			System.out.println("Successfully Created Course Categroy ::" + courseCategory.getId() + "::"
					+ courseCategory.getName());
			return true;
		} else {
			System.out.println(
					"Fail to Create Course Category ::" + courseCategory.getId() + "::" + courseCategory.getName());
			return false;
		}

	}

	public List<CourseCategoryBean> getAllCourseCategory() {

		return courseCategoryReop.getAllCourseCategory();
	}

	public CourseCategoryBean getCourseCategoryById(int courseCategoryId) {

		return courseCategoryReop.getCourseCategoryById(courseCategoryId);
	}

	public boolean updateCoureCategory(int courseCatId, String courseCatName) {

		int result = 0;

		result = courseCategoryReop.updateCourseCategory(courseCatId,courseCatName);

		if (result > 0) {

			System.out.println("Successfully Updated Course Category ::" + courseCatId +"::"
					+ courseCatName);

			return true;
		} else {
			System.out.println(
					"Fail to Update Course Category ::" + courseCatId + "::" + courseCatName);
			return false;
		}
	}

	public boolean deleteCourseCategory(int courseCategoryId) {

		int result = 0;

		result = courseCategoryReop.deleteCourseCategory(courseCategoryId);

		if (result > 0) {
			System.out.println("Successfully Deleted Course Category ::" + courseCategoryId);
			return true;
		} else {
			System.out.println("Fail to Delete Course Category ::" + courseCategoryId);
			return false;
		}
	}

}

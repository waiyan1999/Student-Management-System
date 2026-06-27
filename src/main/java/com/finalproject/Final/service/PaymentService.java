package com.finalproject.Final.service;

import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.finalproject.Final.repository.PaymentRepository;

@Service
public class PaymentService {

    @Autowired
    private PaymentRepository paymentRepository;

    @Autowired
    private EnrollmentService enrollmentService;

    // MAIN FLOW: called when user clicks "Pay"
    public void processPayment(int enrollmentId,
                               int userId,
                               int amount,
                               String paymentMethod,
                               String paymentType,
                               int courseId) {

        // create payment
        int paymentId = paymentRepository.savePayment(
                amount,
                paymentMethod,
                "PENDING",
                courseId
        );

        // create payment record (user link)
        paymentRepository.savePaymentRecord(
                paymentId,
                userId,
                paymentType
        );

        // update enrollment status
        enrollmentService.markAsPaid(enrollmentId);
    }

    // get payment details for UI page
    public Map<String, Object> getPaymentByEnrollment(int enrollmentId) {
        return paymentRepository.getPaymentByEnrollment(enrollmentId);
    }
}
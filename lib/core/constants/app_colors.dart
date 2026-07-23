import 'package:flutter/material.dart';

abstract class AppColors {
  
  AppColors._();

  
  static const Color primary = Color(0xFF0D9488);        
  static const Color primaryDark = Color(0xFF0F766E);
  static const Color primaryContainer = Color(0xFFCCFBF1);
  static const Color onPrimaryContainer = Color(0xFF115E59);

  
  static const Color lightBackground = Color(0xFFF8FAFC);  
  static const Color lightSurface = Color(0xFFFFFFFF);     
  static const Color lightBorder = Color(0xFFE2E8F0);      

  
  static const Color darkBackground = Color(0xFF0F172A);   
  static const Color darkSurface = Color(0xFF1E293B);      
  static const Color darkBorder = Color(0xFF334155);

  
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);

  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  
  static const Color success = Color(0xFF10B981); 
  static const Color error = Color(0xFFEF4444);   
  static const Color warning = Color(0xFFF59E0B); 
  static const Color info = Color(0xFF3B82F6);    

  
  static const Color morning = Color(0xFFF59E0B);  
  static const Color lunch = Color(0xFF10B981);    
  static const Color dinner = Color(0xFF6366F1);   
  static const Color others = Color(0xFF8B5CF6);   
}
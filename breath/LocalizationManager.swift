//
//  LocalizationManager.swift
//  breath
//
//  Created on 2025-11-25.
//

import Foundation
import SwiftUI

class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @AppStorage("selectedLanguage") var selectedLanguage: String = "tr" {
        didSet {
            objectWillChange.send()
        }
    }
    
    private init() {}
    
    func localizedString(_ key: String) -> String {
        let translations: [String: [String: String]] = [
            // App Name & Core
            "app_name": ["tr": "Nefes", "en": "Breath"],
            "app_subtitle": ["tr": "Nefes Egzersizi Uygulaması", "en": "Breathing Exercise App"],
            
            // Tab Bar
            "tab_training": ["tr": "Antrenman", "en": "Training"],
            "tab_history": ["tr": "Geçmiş", "en": "History"],
            "tab_stats": ["tr": "İstatistik", "en": "Statistics"],
            "tab_settings": ["tr": "Ayarlar", "en": "Settings"],
            
            // Training View
            "training_title": ["tr": "Nefes Egzersizleri", "en": "Breathing Exercises"],
            "training_subtitle": ["tr": "Modunu seç ve başla", "en": "Choose mode and start"],
            "mode_hold": ["tr": "Nefes Tutma", "en": "Hold Breath"],
            "mode_hold_subtitle": ["tr": "Kapasiteniz ne kadar?", "en": "What's your capacity?"],
            "mode_exhale": ["tr": "Nefes Verme", "en": "Exhale Control"],
            "mode_exhale_subtitle": ["tr": "Kontrollü nefes egzersizi", "en": "Controlled breathing"],
            "mode_exercise": ["tr": "Egzersiz", "en": "Exercise"],
            "mode_exercise_subtitle": ["tr": "Rehberli nefes seansı", "en": "Guided breathing session"],
            
            // Breath Types
            "breath_hold": ["tr": "Nefes Tutma", "en": "Hold Breath"],
            "breath_exhale": ["tr": "Nefes Verme", "en": "Exhale Control"],
            "breath_exercise": ["tr": "Egzersiz", "en": "Exercise"],
            
            // Exercise View
            "ready": ["tr": "Hazır", "en": "Ready"],
            "hold": ["tr": "Tut", "en": "Hold"],
            "exhale": ["tr": "Ver", "en": "Exhale"],
            "rest": ["tr": "Dinlen", "en": "Rest"],
            "complete": ["tr": "Tamamlandı!", "en": "Complete!"],
            "start": ["tr": "Başla", "en": "Start"],
            "stop": ["tr": "Dur", "en": "Stop"],
            "save": ["tr": "Kaydet", "en": "Save"],
            "settings": ["tr": "Ayarlar", "en": "Settings"],
            "cycle": ["tr": "Döngü", "en": "Cycle"],
            "continue": ["tr": "Devam Et", "en": "Continue"],
            
            // Score Levels
            "score_weak": ["tr": "Zayıf", "en": "Weak"],
            "score_improving": ["tr": "Gelişebilir", "en": "Improving"],
            "score_good": ["tr": "İyi", "en": "Good"],
            "score_swimmer": ["tr": "Yüzücü", "en": "Swimmer"],
            "score_excellent": ["tr": "Mükemmel", "en": "Excellent"],
            "score_diver": ["tr": "Dalışçı", "en": "Diver"],
            
            // History View
            "history_title": ["tr": "Geçmiş", "en": "History"],
            "filter_all": ["tr": "Tümü", "en": "All"],
            "no_records": ["tr": "Henüz kayıt yok", "en": "No records yet"],
            "no_records_subtitle": ["tr": "İlk nefes egzersizini yapmaya başla!", "en": "Start your first breathing exercise!"],
            "today": ["tr": "Bugün", "en": "Today"],
            "yesterday": ["tr": "Dün", "en": "Yesterday"],
            
            // Stats View
            "stats_title": ["tr": "İstatistikler", "en": "Statistics"],
            "timeframe_today": ["tr": "Bugün", "en": "Today"],
            "timeframe_week": ["tr": "Hafta", "en": "Week"],
            "timeframe_month": ["tr": "Ay", "en": "Month"],
            "total_sessions": ["tr": "Toplam Seans", "en": "Total Sessions"],
            "total_duration": ["tr": "Toplam Süre", "en": "Total Duration"],
            "best_hold": ["tr": "En İyi Tutma", "en": "Best Hold"],
            "average": ["tr": "Ortalama", "en": "Average"],
            "performance_chart": ["tr": "Performans Grafiği", "en": "Performance Chart"],
            "best_scores": ["tr": "En İyi Skorlar", "en": "Best Scores"],
            
            // Settings View
            "settings_title": ["tr": "Ayarlar", "en": "Settings"],
            "appearance": ["tr": "Görünüm", "en": "Appearance"],
            "dark_mode": ["tr": "Koyu Mod", "en": "Dark Mode"],
            "language": ["tr": "Dil", "en": "Language"],
            "language_turkish": ["tr": "Türkçe", "en": "Turkish"],
            "language_english": ["tr": "İngilizce", "en": "English"],
            "notifications": ["tr": "Bildirimler", "en": "Notifications"],
            "notification_settings": ["tr": "Bildirim Ayarları", "en": "Notification Settings"],
            "notifications_enabled": ["tr": "Bildirimler açık", "en": "Notifications enabled"],
            "permission_required": ["tr": "İzin Gerekli", "en": "Permission Required"],
            "grant_permission": ["tr": "İzin Ver", "en": "Grant Permission"],
            "frequency": ["tr": "Sıklık", "en": "Frequency"],
            "daily": ["tr": "Her Gün", "en": "Daily"],
            "weekdays": ["tr": "Hafta İçi", "en": "Weekdays"],
            "add_new_time": ["tr": "Yeni Saat Ekle", "en": "Add New Time"],
            "notification_footer": ["tr": "Seçtiğiniz saatlerde günlük nefes egzersizi hatırlatıcıları alacaksınız.", "en": "You'll receive daily breathing exercise reminders at selected times."],
            "daily_tasks": ["tr": "Günlük Görevler", "en": "Daily Tasks"],
            "statistics": ["tr": "İstatistikler", "en": "Statistics"],
            "total_records": ["tr": "Toplam Kayıt", "en": "Total Records"],
            "today_sessions": ["tr": "Bugünkü Seans", "en": "Today's Sessions"],
            "data_management": ["tr": "Veri Yönetimi", "en": "Data Management"],
            "delete_all_data": ["tr": "Tüm Verileri Sil", "en": "Delete All Data"],
            "about": ["tr": "Hakkında", "en": "About"],
            "version": ["tr": "Versiyon", "en": "Version"],
            
            // Alerts & Navigation
            "back": ["tr": "Geri", "en": "Back"],
            "delete_all": ["tr": "Tüm Verileri Sil", "en": "Delete All Data"],
            "delete_message": ["tr": "Bu işlem geri alınamaz. Tüm nefes kayıtlarınız silinecek.", "en": "This action cannot be undone. All your breathing records will be deleted."],
            "cancel": ["tr": "İptal", "en": "Cancel"],
            "delete": ["tr": "Sil", "en": "Delete"],
            "ok": ["tr": "Tamam", "en": "OK"],
            "add": ["tr": "Ekle", "en": "Add"],
            
            // Add Notification Time
            "new_reminder": ["tr": "Yeni Hatırlatıcı", "en": "New Reminder"],
            "select_time": ["tr": "Saat Seç", "en": "Select Time"],
            "add_reminder": ["tr": "Hatırlatıcı Ekle", "en": "Add Reminder"],
            
            // Daily Tasks
            "task_hold_3": ["tr": "3 nefes tutma denemesi yap", "en": "Complete 3 breath hold attempts"],
            "task_exhale_5": ["tr": "5 kez kontrollü nefes ver", "en": "Do 5 controlled exhales"],
            "task_exercise_2": ["tr": "2 egzersiz seansı tamamla", "en": "Complete 2 exercise sessions"],
            
            // Hold Breath View
            "hold_title": ["tr": "Nefes Tutma", "en": "Hold Breath"],
            "hold_subtitle": ["tr": "Butona basılı tut", "en": "Press and hold button"],
            "hold_instruction": ["tr": "Basılı tutun ve nefesi tutun 🫁", "en": "Hold and keep your breath 🫁"],
            
            // Exhale Breath View
            "exhale_title": ["tr": "Nefes Verme", "en": "Exhale Control"],
            "exhale_subtitle": ["tr": "Butona basılı tut", "en": "Press and hold button"],
            "exhale_instruction": ["tr": "Basılı tutun ve yavaşça nefes verin 🌬️", "en": "Hold and slowly exhale 🌬️"],
            
            // Exercise View
            "exercise_title": ["tr": "Egzersiz", "en": "Exercise"],
            "relax_get_ready": ["tr": "Rahatla ve hazır ol", "en": "Relax and get ready"],
            "great_job": ["tr": "Harika İş!", "en": "Great Job!"],
            "cycles_completed": ["tr": "tur tamamlandı", "en": "cycles completed"],
            "restart": ["tr": "Tekrar Başla", "en": "Restart"],
            "cycle_progress": ["tr": "Tur:", "en": "Cycle:"],
            "inhale": ["tr": "Nefes Al", "en": "Inhale"],
            
            // Exercise Config View
            "exercise_settings": ["tr": "Egzersiz Ayarları", "en": "Exercise Settings"],
            "hold_duration": ["tr": "Nefes Tutma", "en": "Hold Duration"],
            "exhale_duration": ["tr": "Nefes Verme", "en": "Exhale Duration"],
            "rest_duration": ["tr": "Dinlenme", "en": "Rest Duration"],
            "cycle_count": ["tr": "Tur Sayısı", "en": "Cycle Count"],
            "seconds": ["tr": "saniye", "en": "seconds"],
            "minutes": ["tr": "dakika", "en": "minutes"],
            "cycles": ["tr": "tur", "en": "cycles"],
            "config_total_duration": ["tr": "Toplam süre:", "en": "Total duration:"],
            
            // Notification Messages
            "notif_msg_1": ["tr": "Bir nefes molası iyi gider 😌", "en": "A breathing break would be good 😌"],
            "notif_msg_2": ["tr": "30 saniyelik bir nefes reseti ister misin?", "en": "Want a 30-second breathing reset?"],
            "notif_msg_3": ["tr": "Bugünkü görevin seni bekliyor.", "en": "Your daily task is waiting."],
            "notif_msg_4": ["tr": "Derin bir nefes almak için harika bir zaman! 🌬️", "en": "Great time for a deep breath! 🌬️"],
            "notif_msg_5": ["tr": "Biraz durup nefes egzersizi yapalım mı?", "en": "Shall we pause for a breathing exercise?"],
            "notif_msg_6": ["tr": "Nefesine odaklanma zamanı 🧘‍♂️", "en": "Time to focus on your breath 🧘‍♂️"],
            "notif_msg_7": ["tr": "Kısa bir nefes molası verelim mi?", "en": "How about a quick breathing break?"],
            "notif_msg_8": ["tr": "Bugün kaç nefes egzersizi yaptın? 💪", "en": "How many breathing exercises did you do today? 💪"],
            "notif_title": ["tr": "Nefes Egzersizi", "en": "Breathing Exercise"],
            "notif_task_title": ["tr": "Günlük Görev", "en": "Daily Task"],
            "notif_task_body": ["tr": "Bugünkü nefes egzersizi görevlerini tamamlamayı unutma! 💪", "en": "Don't forget to complete today's breathing exercise tasks! 💪"],
        ]
        
        return translations[key]?[selectedLanguage] ?? key
    }
}

// String extension for easier localization
extension String {
    var localized: String {
        LocalizationManager.shared.localizedString(self)
    }
}

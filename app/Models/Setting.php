<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Setting extends Model
{
    protected $fillable = [
        'header_logo',
        'footer_logo',
        'favicon',
        'site_title',
        'site_description',
        'tagline',
        'footer_text',
        'theme_color',
        'background_color',
        'font_color',
        'font_style',
        'sidebar_text_color',
        'heading_text_color',
        'label_text_color',
        'general_text_color',
        'link_color',
        'link_hover_color',
        'facebook_url',
        'twitter_url',
        'instagram_url',
        'linkedin_url',
        'youtube_url',
        'whatsapp_url',
        'maintenance_mode',
        'maintenance_end_time',
        'maintenance_message',
        'coming_soon_mode',
        'launch_time',
        'coming_soon_message',
        'razorpay_key_id',
        'razorpay_key_secret',
        'app_store_link',
        'play_store_link',
        'firebase_project_id',
        'firebase_client_email',
        'firebase_private_key',
    ];
}
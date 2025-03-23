/**
 * Configuration file for Link Shortener app
 * 
 * This file sets runtime configuration variables for the application
 * Values can be edited directly for local development or modified by CI/CD for production.
 */
window.APP_CONFIG = {
    // API base URL - modify for your environment
    // URL API-сервера - измените для вашего окружения
    apiBaseUrl: "https://short.twb.one", 
    
    // Environment: development, staging, production
    // Окружение: development, staging, production
    environment: "development"
};

console.log("Link Shortener configuration loaded:", window.APP_CONFIG);

// Enable Firebase Analytics Debug Mode
(function() {
  console.log('🔍 Enabling Firebase Analytics Debug Mode...');
  
  // Set debug mode flag
  window['ga-disable-G-5KNGG8SPQN'] = false;
  
  // Enable debug_mode parameter
  if (typeof gtag === 'function') {
    gtag('config', 'G-5KNGG8SPQN', {
      'debug_mode': true
    });
  }
  
  console.log('✅ Firebase Analytics Debug Mode enabled');
})();

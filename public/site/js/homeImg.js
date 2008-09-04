var bannerImg = new Array();
  // Enter the names of the images below
  bannerImg[0]="/galleries/default-image/home_splash01.jpg";
  bannerImg[1]="/galleries/default-image/home_splash02.jpg";
  bannerImg[2]="/galleries/default-image/home_splash03.jpg";
  bannerImg[3]="/galleries/default-image/home_splash04.jpg";
  bannerImg[4]="/galleries/default-image/home_splash05.jpg";
 
var newBanner = 0;
var totalBan = bannerImg.length;

function cycleBan() {
  newBanner++;
  if (newBanner == totalBan) {
    newBanner = 0;
  }
  document.banner.src=bannerImg[newBanner];
  // set the time below for length of image display
  // i.e., "4*1000" is 4 seconds
  setTimeout("cycleBan()", 8*1000);
}
window.onload=cycleBan;

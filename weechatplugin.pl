#!/usr/bin/perl
#	
#	Download all the images!!!
#		https://github.com/T00mm
require LWP::UserAgent;
my $ua = LWP::UserAgent->new;
$ua->timeout(10);
$ua->env_proxy;
@imageurl = ();
weechat::register("image_collector", "Tom", "1.0", "GPL3", "Collect all the images and put them in a folder!", "", "");
weechat::hook_print(NULL, "notify_message", "://", 1, "isimage", "");
weechat::print(NULL, "[ImageC] Image grabber, gogogogo");
sub isimage {	
	my ( $data, $buffer, $date, $tags, $displayed, $highlight, $prefix, $message ) = @_;
	%uris = ();
	if($message =~ /(http|https):\/\/(.*)(jpg|png|jpeg|gif)/i)
	{
		if(!-d "~/images/") {
			weechat::print(NULL, "[ImageC] No image folder exist!");
			if(!weechat::mkdir("~/images",0755))
			{
				weechat::print(NULL, "[ImageC] Couldn't make image-folder in home directory");
				exit();
			}
		}
		$url = "$1://$2$3";
		if ( grep $_ eq $url, @imageurl ) {
			$url = "";
		}		
			if ($url =~ /(gif|png|jpg|jpeg)/i) 
			{	
				$filename = "$date.$1";
				$buffern = weechat::buffer_get_string($buffer,"name");
				weechat::print($buffer,"Found an image! (images/$buffer/$filename) from $url"); 
				if(!-d $buffer){	
					if(!weechat::mkdir("~/images/$buffern",0755))
					{
						weechat::print(NULL, "[ImageC] Couldn't make extra folder in home-directory!");
						exit();						
					} 
				} 
				$rs = $ua->get($url); 
				push(@imageurl,$url);
				if($rs->is_success){ 
					if(!-d "~/images/$buffern")
					{
						weechat::print(NULL, "[ImageC] The folder for storage doesn't exist");
						exit();
					}
					open (F, ">~/images/$buffern/$filename") or die ("Couldn't open"); 
					binmode (F);	
					print F $rs->content;
					close (F);
				}
				
			}
		
	}
	return weechat::WEECHAT_RC_OK;
}
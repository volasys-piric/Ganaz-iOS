//
//  Global.h
//  Ganaz
//
//  Created by Piric Djordje on 2/18/17.
//  Copyright © 2017 Ganaz. All rights reserved.
//

#ifndef Global_h
#define Global_h

#define GANLOG( s, ... ) NSLog( @"%s: %@ l=>%d", __FUNCTION__, [NSString stringWithFormat:(s), ##__VA_ARGS__], __LINE__ )

#warning This should be removed before submission!
#define GANENVIRONMENT_STAGING

// BASE URL

#ifdef GANENVIRONMENT_STAGING

#define ONESIGNAL_APPID                             @"37c1d731-1cbd-40cf-9ba3-3936174602e1"
#define GANURL_BASEURL                              @"http://35.166.132.188:8000/api/v1"

#elif GANENVIRONMENT_DEV

#define ONESIGNAL_APPID                             @"37c1d731-1cbd-40cf-9ba3-3936174602e1"
#define GANURL_BASEURL                              @"http://34.210.63.91:8000/api/v1"

#else

#define ONESIGNAL_APPID                             @"160b5387-8178-46e2-b194-ad193dc5efac"
#define GANURL_BASEURL                              @"http://35.163.42.136:8000/api/v1"

#endif

#define GANURL_APPSTORE                             @"https://itunes.apple.com/app/id1230180278"

// CONSTANTS

#define TRANSITION_FADEOUT_DURATION                         0.25f

#define GANLOCATION_DEFAULT_LATITUDE                        40.7128
#define GANLOCATION_DEFAULT_LONGITUDE                       -74.0059
#define GOOGLEMAPS_API_KEY                                  @"AIzaSyCrYm3QN8cfIN5rbGcFHBEGSAye8G4lUho"
#define GOOGLE_TRANSLATE_API_KEY                            @"AIzaSyCVm0nvaYBqtNOOepzALr7iCKNW1_96J6o"

// UICOLOR

#define GANUICOLOR_THEMECOLOR_MAIN                              [UIColor colorWithRed:(51 / 255.0) green:(51 / 255.0) blue:(51 / 255.0) alpha:1]
#define GANUICOLOR_THEMECOLOR_TABBAR_SELECTED                   [UIColor colorWithRed:(67 / 255.0) green:(137 / 255.0) blue:(6 / 255.0) alpha:1]
#define GANUICOLOR_THEMECOLOR_PLACEHOLDER                       [UIColor colorWithRed:(255 / 255.0) green:(255 / 255.0) blue:(255 / 255.0) alpha:0.5]
#define GANUICOLOR_UIBUTTON_DELETE_BORDERCOLOR                  [UIColor colorWithRed:(51 / 255.0) green:(51 / 255.0) blue:(51 / 255.0) alpha:0.6]
#define GANUICOLOR_BADGE_GOLD                                   [UIColor colorWithRed:(251 / 255.0) green:(205 / 255.0) blue:(67 / 255.0) alpha:1]
#define GANUICOLOR_BADGE_SILVER                                 [UIColor colorWithRed:(209 / 255.0) green:(217 / 255.0) blue:(223 / 255.0) alpha:1]

// Error Code

#define SUCCESS_WITH_NO_ERROR                       200
#define SUCCESS_WITH_CREATE                         201

#define ERROR_BAD_REQUEST                           400
#define ERROR_UNAUTHORIZED                          401
#define ERROR_FORBIDDEN                             403
#define ERROR_NOT_FOUND                             404
#define ERROR_VERSION_EXPIRED                       412
#define ERROR_USER_NEWDEVICE                        419
#define ERROR_USER_DISABLED                         420
#define ERROR_REQUEST_FLOOD                         429
#define ERROR_USER_INVALID_PHONECARRIER             461
#define ERROR_USER_INVALID_PHONENUMBER              462
#define ERROR_CONNECTION_FAILED                     499
#define ERROR_INTERNAL_SERVER_ERROR                 500
#define ERROR_UNKNOWN                               520
#define ERROR_MAINTENANCE_MODE                      555

#define ERROR_USER_SIGNUPFAILED_USERNAMECONFLICT    1001
#define ERROR_USER_SIGNUPFAILED_EMAILCONFLICT       1002
#define ERROR_USER_LOGINFAILED_USERNOTFOUND         1003
#define ERROR_USER_LOGINFAILED_PASSWORDWRONG        1004

#define GANLOCALNOTIFICATION_USER_SILENTLOGIN_SUCCEEDED                 @"GANLOCALNOTIFICATION_USER_SILENTLOGIN_SUCCEEDED"
#define GANLOCALNOTIFICATION_USER_SILENTLOGIN_FAILED                    @"GANLOCALNOTIFICATION_USER_SILENTLOGIN_FAILED"
#define GANLOCALNOTIFICATION_COMPANY_JOBLIST_UPDATED                    @"GANLOCALNOTIFICATION_COMPANY_JOBLIST_UPDATED"
#define GANLOCALNOTIFICATION_COMPANY_JOBLIST_UPDATEFAILED               @"GANLOCALNOTIFICATION_COMPANY_JOBLIST_UPDATEFAILED"
#define GANLOCALNOTIFICATION_COMPANY_MYWORKERSLIST_UPDATED              @"GANLOCALNOTIFICATION_COMPANY_MYWORKERSLIST_UPDATED"
#define GANLOCALNOTIFICATION_COMPANY_MYWORKERSLIST_UPDATEFAILED         @"GANLOCALNOTIFICATION_COMPANY_MYWORKERSLIST_UPDATEFAILED"
#define GANLOCALNOTIFICATION_MESSAGE_LIST_UPDATED                       @"GANLOCALNOTIFICATION_MESSAGE_LIST_UPDATED"
#define GANLOCALNOTIFICATION_MESSAGE_LIST_UPDATEFAILED                  @"GANLOCALNOTIFICATION_MESSAGE_LIST_UPDATEFAILED"
#define GANLOCALNOTIFICATION_WORKER_JOBSEARCH_UPDATED                   @"GANLOCALNOTIFICATION_WORKER_JOBSEARCH_UPDATED"
#define GANLOCALNOTIFICATION_WORKER_JOBSEARCH_UPDATEFAILED              @"GANLOCALNOTIFICATION_WORKER_JOBSEARCH_UPDATEFAILED"
#define GANLOCALNOTIFICATION_WORKER_JOBSEARCH_FILTER_UPDATED            @"GANLOCALNOTIFICATION_WORKER_JOBSEARCH_FILTER_UPDATED"
#define GANLOCALNOTIFICATION_REVIEW_LIST_UPDATED                        @"GANLOCALNOTIFICATION_REVIEW_LIST_UPDATED"
#define GANLOCALNOTIFICATION_REVIEW_LIST_UPDATE_FAILED                  @"GANLOCALNOTIFICATION_REVIEW_LIST_UPDATE_FAILED"
#define GANLOCALNOTIFICATION_LOCATION_UPDATED                           @"GANLOCALNOTIFICATION_LOCATION_UPDATED"
#define GANLOCALNOTIFICATION_CONTENTS_TRANSLATED                        @"GANLOCALNOTIFICATION_CONTENTS_TRANSLATED"
#define GANLOCALNOTIFICATION_MEMBERSHIPPLAN_LIST_UPDATED                @"GANLOCALNOTIFICATION_MEMBERSHIPPLAN_LIST_UPDATED"
#define GANLOCALNOTIFICATION_MEMBERSHIPPLAN_LIST_UPDATE_FAILED          @"GANLOCALNOTIFICATION_MEMBERSHIPPLAN_LIST_UPDATE_FAILED"

#define LOCALSTORAGE_PREFIX                                             @"GANAZLOCALSTORAGE_"
#define LOCALSTORAGE_USER_LOGIN                                         @"USER_LOGIN"

#endif /* Global_h */

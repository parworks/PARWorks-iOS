//
//  ARConstants.h
//  PAR Works iOS SDK
//
//  Copyright 2013 PAR Works, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//


#ifndef HD4ARClient_iOS_ARConstants_h
#define HD4ARClient_iOS_ARConstants_h

#define API_ROOT                        @"mars.parworksapi.com"

#define REQ_SITE                        @"/ar/site"
#define REQ_SITE_ADD                    @"/ar/site/add"
#define REQ_SITE_LIST                   @"/ar/site/list"
#define REQ_SITE_LIST_ALL               @"/ar/site/list/summary?trimResult=true"
#define REQ_SITE_REMOVE                 @"/ar/site/remove"
#define REQ_SITE_NEARBY                 @"/ar/site/nearby"
#define REQ_SITE_INFO                   @"/ar/site/info"
#define REQ_SITE_INFO_SINGLE            @"/ar/site/info/summary"
#define REQ_SITE_OVERLAYS               @"/ar/site/overlay"
#define REQ_SITE_OVERLAY_ADD            @"/ar/site/overlay/add"
#define REQ_SITE_OVERLAY_REMOVE         @"/ar/site/overlay/staging/remove"
#define REQ_SITE_OVERLAY_REPROCESS      @"/ar/site/overlay/staging/add"
#define REQ_SITE_OVERLAY_REMOVE_STAGING @"/ar/site/overlay/remove"
#define REQ_SITE_OVERLAY_CLICK          @"/ar/site/overlay/click"
#define REQ_SITE_PROCESS                @"/ar/site/process"
#define REQ_SITE_POSTER                 @"/ar/site/info/poster"
#define REQ_SITE_CHANGE_DETECT          @"/ar/site/change/detect"
#define REQ_SITE_CHANGE_DETECT_RESULT   @"/ar/site/change/detect/result"

#define REQ_SITE_IMAGE                  @"/ar/site/image"
#define REQ_SITE_IMAGE_ADD              @"/ar/site/image/add"
#define REQ_SITE_IMAGE_REMOVE           @"/ar/site/image/remove"
#define REQ_SITE_IMAGE_REGISTERED       @"/ar/site/image/registered"
#define REQ_SITE_IMAGE_LIST_AUGMENTED   @"/ar/site/image/augmented/list"
#define REQ_SITE_VIDEO_ADD              @"/ar/site/video/add"

#define REQ_IMAGE_AUGMENT               @"/ar/image/augment"
#define REQ_IMAGE_AUGMENT_GEO           @"/ar/image/augment/geo"
#define REQ_IMAGE_AUGMENT_MULTI         @"/ar/image/augment/group?site="
#define REQ_IMAGE_AUGMENT_RESULT        @"/ar/image/augment/result"
#define REQ_IMAGE_AUGMENT_MULTI_RESULT_NO_POLL @"/ar/image/augment/group/result?site="

#define REQ_USER_REGISTER               @"/ar/mars/user/account/create"
#define REQ_USER_GETKEY                 @"/ar/mars/user/account/getkey"


#define NOTIF_SITE_UPDATED              @"nbu"
#define NOTIF_SITES_UPDATED             @"nbua"
#define NOTIF_AUGMENTED_PHOTO_UPDATED   @"napu"
#define NOTIF_UPLOAD_COMPLETED_IN_SITE  @"ucis"
#define NOTIF_UPLOADS_UPDATED           @"nuu"
#define NOTIF_UPLOAD_STATUS_CHANGE      @"nusc"

typedef enum BackendResponse {
    WaitingToUpload = -1,
    BackendResponseFailed = 0,
    BackendResponseUploading = 1,
    BackendResponseProcessing = 2,
    BackendResponseFinished = 3
} BackendResponse;

#endif

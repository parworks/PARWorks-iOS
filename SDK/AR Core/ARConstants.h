//
//  ARConstants.h
//  PAR Works iOS SDK
//
//  Copyright 2012 PAR Works, Inc.
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

#define REQ_BASE_PROCESS                @"/ar/site/process"
#define REQ_BASE_PROCESS_STATE          @"/ar/site/process/state"

#define REQ_SITE                        @"/ar/site"
#define REQ_SITE                        @"/ar/site"
#define REQ_SITE_ADD                    @"/ar/site/add"
#define REQ_SITE_LIST                   @"/ar/site/list"
#define REQ_SITE_REMOVE                 @"/ar/site/remove"
#define REQ_SITE_NEARBY                 @"/ar/site/nearby"
#define REQ_SITE_INFO                   @"/ar/site/info"
#define REQ_SITE_REMOVE                 @"/ar/site/remove"
#define REQ_SITE_OVERLAYS               @"/ar/site/overlay"

#define REQ_SITE_IMAGE                  @"/ar/site/image"
#define REQ_SITE_IMAGE_ADD              @"/ar/site/image/add"

#define REQ_IMAGE_AUGMENT               @"/ar/image/augment"
#define REQ_IMAGE_AUGMENT_GEO           @"/ar/image/augment/geo"
#define REQ_IMAGE_AUGMENT_RESULT        @"/ar/image/augment/result"

#define NOTIF_SITE_UPDATED              @"nbu"
#define NOTIF_AUGMENTED_PHOTO_UPDATED   @"napu"

typedef enum BackendResponse {
    BackendResponseFailed = 0,
    BackendResponseUploading = 1,
    BackendResponseProcessing = 2,
    BackendResponseFinished = 3
} BackendResponse;

#endif

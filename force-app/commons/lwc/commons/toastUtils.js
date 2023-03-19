/*
 * *
 *  MIT License
 *
 *  Copyright (c) 2023 Piotr Kożuchowski
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in all
 *  copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 *  SOFTWARE.
 */

import {ShowToastEvent} from "lightning/platformShowToastEvent";

export class ToastUtils {

    static showUnexpectedErrorToast(cmp) {
        ToastUtils.showErrorToast(cmp,
            "Unexpected error has occurred. Try again or contact your Salesforce administrator for help."
        );
    }

    static showErrorToast(cmp, title, message, messageData, mode) {
        ToastUtils.showToast(cmp, "error", title, message, messageData, mode)
    }

    static showWarningToast(cmp, title, message, messageData, mode) {
        ToastUtils.showToast(cmp, "warning", title, message, messageData, mode)
    }

    static showInfoToast(cmp, title, message, messageData, mode) {
        ToastUtils.showToast(cmp, "info", title, message, messageData, mode)
    }

    static showSuccessToast(cmp, title, message, messageData, mode) {
        ToastUtils.showToast(cmp, "success", title, message, messageData, mode)
    }

    static showToast(cmp, variant, title, message, messageData, mode) {
        cmp.dispatchEvent(new ShowToastEvent({
            variant, title, message, messageData, mode
        }));
    }
}
/**
 * MIT License
 *
 * Copyright (c) 2019 Piotr Kożuchowski
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
public inherited sharing class TriggerDispatcher {
    /**
     * Runs instance of concrete Trigger Handler implementation
     */
    public static void run(TriggerHandler triggerHandler) {
        run(triggerHandler, TriggerContext.getInstance());
    }

    @TestVisible
    private static void run(TriggerHandler triggerHandler, TriggerContext triggerContext) {
        try {
            if (shouldRun(triggerContext, triggerHandler)) {
                switch on triggerContext.operationType {
                    when BEFORE_INSERT {
                        TriggerUtils.logRecordInserts(triggerContext.getRecords(), true);
                        triggerHandler.beforeInsert(triggerContext.getRecords(), triggerContext);
                    }
                    when BEFORE_UPDATE {
                        TriggerUtils.logRecordUpdates(triggerContext.getRecords(), triggerContext.getOldMap(), true);
                        triggerHandler.beforeUpdate(triggerContext.getRecords(), triggerContext);
                    }
                    when BEFORE_DELETE {
                        TriggerUtils.logRecordDeletes(triggerContext.getRecords(), true);
                        triggerHandler.beforeDelete(triggerContext.getRecords(), triggerContext);
                    }
                    when AFTER_INSERT {
                        TriggerUtils.logRecordInserts(triggerContext.getRecords(), false);
                        triggerHandler.afterInsert(triggerContext.getRecords(), triggerContext);
                    }
                    when AFTER_UPDATE {
                        TriggerUtils.logRecordUpdates(triggerContext.getRecords(), triggerContext.getOldMap(), false);
                        triggerHandler.afterUpdate(triggerContext.getRecords(), triggerContext);
                    }
                    when AFTER_DELETE {
                        TriggerUtils.logRecordDeletes(triggerContext.getRecords(), false);
                        triggerHandler.afterDelete(triggerContext.getRecords(), triggerContext);
                    }
                    when AFTER_UNDELETE {
                        TriggerUtils.logRecordInserts(triggerContext.getRecords(), false);
                        triggerHandler.afterUndelete(triggerContext.getRecords(), triggerContext);
                    }
                }
            }
        } catch (Exception e) {
            if (Test.isRunningTest()) {
                throw e;
            }

            List<SObject> records = triggerContext.isDelete
                ? triggerContext.getOldMap().values()
                : triggerContext.getRecordsMap().values();

            for (SObject record : records) {
                record.addError('An unexpected error occurred. Please contact your administrator.');
                Logger.error(new LogMessage('Unhandled Exception: {0}', e.getMessage()), record).setExceptionDetails(e);
            }

            Logger.saveLog();
        }
    }

    /**
     * @return True when:
     * - is in trigger context (can be mocked in unit tests)
     * - if it's not disabled in Bypass Triggers settings
     * - if it's not manually disabled in code via  disableTrigger();
     */
    private static Boolean shouldRun(TriggerContext triggerContext, TriggerHandler th) {
        String thName = th.toString().substringBefore(':');
        return triggerContext.isExecuting &&
            TriggerSettings.isSObjectTriggerEnabled(triggerContext.sObjectType) &&
            TriggerSettings.isTriggerHandlerEnabled(thName);
    }

    private TriggerDispatcher() {
    }
}

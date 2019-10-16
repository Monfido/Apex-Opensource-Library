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

/**
 * Applies default values to records in trigger.
 */
public with sharing class SObjectFieldDefaults {

    /**
     * Applies Field Default Rules defined in custom metadata.
     */
    public static void apply(List<SObject> records, TriggerContext tc) {
        apply(records, tc, getConfiguredFieldDefaultRules(tc));
    }

    /**
     * Applies given FieldDefaultRules to inserted or updated records.
     */
    public static void apply(List<SObject> records, TriggerContext tc, List<FieldDefaultRule> populators) {
        for (FieldDefaultRule fieldDefaultRule : populators) {
            fieldDefaultRule.prepare(records, tc);

            for (SObject record : records) {
                fieldDefaultRule.populate(record, tc);
            }
        }
    }


    /**
     * @return ValidationRules defined in custom metadata.
     */
    private static List<FieldDefaultRule> getConfiguredFieldDefaultRules(TriggerContext tc) {
        List<FieldDefaultRule> fieldDefaultsRules = new List<FieldDefaultRule>();

        for (ApexFieldDefaultRule__mdt setting : [
                SELECT ApexClass__c, DeveloperName
                FROM ApexFieldDefaultRule__mdt
                WHERE IsEnabled__c = TRUE
                AND SObject__c = :String.valueOf(tc.sObjectType)
                AND Trigger__c = :tc.operationType.name()
                ORDER BY Order__c NULLS LAST
        ]) {
            try {
                Type ruleClass = Type.forName(setting.ApexClass__c);
                FieldDefaultRule rule = (FieldDefaultRule) ruleClass.newInstance();
                fieldDefaultsRules.add(rule);

            } catch (Exception ex) {
                throw new TypeException('Field Default Rule "' + setting.DeveloperName + '" is invalid. ' +
                        'Please check if corresponding class is public and implements FieldDefaultRule interface.');
            }
        }

        return fieldDefaultsRules;
    }
}
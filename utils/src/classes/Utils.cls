public class Utils {

    public static Boolean isAdminUser() {
        Id adminProfId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'][0].Id;
        return adminProfId == UserInfo.getProfileId();
    }

    public static Map<Id, List<sObject>> splitListBySpecialKey(List<sObject> sourceList, String key) {
        if (sourceList == null) {
            throw new IncorrectParameterException('ERROR: Utils.splitListBySpecialKey(sourceList, key) got incorrect first parameter.');
        }
        if (String.isBlank(key)) {
            throw new IncorrectParameterException('ERROR: Utils.splitListBySpecialKey(sourceList, key) got incorrect second parameter.');
        }
        Map<Id, List<sObject>> result = new Map<Id, List<sObject>>();
        List<sObject> tmpObjs;
        for (sObject obj : sourceList) {
            tmpObjs = new List<sObject>();
            if (obj.get(key) != null && result.containsKey((Id)obj.get(key))) {
                tmpObjs = result.get((Id)obj.get(key));
                tmpObjs.add(obj);
                result.put((Id)obj.get(key), tmpObjs);
            } else if (obj.get(key) != null) {
                tmpObjs.add(obj);
                result.put((Id)obj.get(key), tmpObjs);
            }
        }
        return result;
    }

    /**
     * verifies that given String is Salesforce record Id
     * @param   verifyingId String which should be tested
     * @return  Boolean
     */
    public static Boolean isRecordId(String verifyingId) {
        System.debug(LoggingLevel.DEBUG, verifyingId);
        if (verifyingId.length() == 15 || verifyingId.length() == 18 ) {
            Pattern id = Pattern.compile('[A-Za-z0-9]{15,18}');
            Matcher matcher = id.matcher(verifyingId);
            if (!matcher.find()) {
                return false;
            } else {
                return true;
            }
        } else {
            return false;
        }
    }


    /**
     * GUID is a Globally Unique Identifier which is used as External Id for Traffic
     * @author              Pavel Slepenkov(pavel.slepenkov@gmail.com)
     * @return              String random GUID
     */
    public static String generateRandomGUID() {
        // GUID Format {xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx}
        List<Integer> groupSizes = new List<Integer>{8,4,4,4,12};
        String delimiter = '-';
        final String chars = 'ABCDEF123456789abcdef';
        List<String> chunks = new List<String>();
        String randStr = '';
        for (Integer i = 0; i < groupSizes.size(); i++) {
            while (randStr.length() < groupSizes[i]) {
               Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
               randStr += chars.substring(idx, idx+1);
            }
            chunks.add(randStr);
            randStr = '';
        }
        String result = String.join( chunks, delimiter );
        return result;
    }




    public class IncorrectParameterException extends System.Exception {}
}
# [#644] External User

Support a built in way to authenticate external users and store their information in the database. These users could be from any system (CRM, AMS, Facebook) and they would be authenticated using credentials from those services. Each external user would be given a record in the user table and would be marked as an external user.

* Permission: Groups would be dynamically assigned on login and recorded as an association with that user until they reauthentice.
* External Data: Third Party APIs often provide extra information. Provide an easy way to store this information on the user record without needing new columns.
* Subclasses: Projects/Engines should be able to subclass ExternalUser to provide additional behavior.

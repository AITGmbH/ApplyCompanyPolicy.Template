### 1.3.0

 * Smaller rule changes (disable SA1513 and SA1516 because they are not compatible with no empty line between C# getters and setters and R# has no settings for it to insert the blank line on full-cleanup).
 * Update documentation and add a how-to for creating packages (https://aitgmbh.github.io/ApplyCompanyPolicy.Template/CreatePackage.html).

### 1.3.0-alpha6

 * remove 'this.' on full cleanup.

### 1.3.0-alpha5

 * Update description on the nuget page.

### 1.3.0-alpha4

 * Don't show hint to insert 'this' when no 'this' is used.

### 1.3.0-alpha3

 * Rename repository and all links.

### 1.3.0-alpha2

 * Make sure the package is installable by including "ghost" references to the System framework assembly.

### 1.3.0-alpha1

 * fixed some inconsistencies between R# and StyleCop.
 * enabled some ordering rules, in combination with a R# configuration to automatically create the ordering.
